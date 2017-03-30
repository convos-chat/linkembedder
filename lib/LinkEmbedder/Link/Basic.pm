package LinkEmbedder::Link::Basic;
use Mojo::Base 'LinkEmbedder::Link';

use Mojo::Util 'trim';

my $PHOTO_RE = qr!\.(?:jpg|png|gif)\b!i;
my $VIDEO_RE = qr!\.(?:mpg|mpeg|mov|mp4|ogv)\b!i;

has description => '';

sub learn {
  my ($self, $cb) = @_;
  my $url = $self->url;
  my $type = $url =~ $PHOTO_RE ? 'photo' : $url =~ $VIDEO_RE ? 'video' : 'link';

  $self->type($type);

  # Need to learn more from an http request
  if ($type eq 'link') {
    if ($cb) {
      $self->ua->get($url => sub { $self->_learn($_[1])->$cb });
    }
    else {
      $self->_learn($self->ua->get($url));
    }
  }
  else {
    $self->_learn_from_url;
    $self->$cb if $cb;
  }

  return $self;
}

sub _learn {
  my ($self, $tx) = @_;
  my $ct = $tx->res->headers->content_type || '';

  $self->type('photo')->_learn_from_url               if $ct =~ m!^image/!;
  $self->type('video')->_learn_from_url               if $ct =~ m!^video/!;
  $self->type('rich')->_learn_from_url                if $ct =~ m!^text/plain!;
  $self->type('rich')->_learn_from_dom($tx->res->dom) if $ct =~ m!^text/html!;

  return $self;
}

sub _learn_from_dom {
  my ($self, $dom) = @_;

  $self->_val(author_name => $dom, '[itemprop="author"] [itemprop="name"]');
  $self->_val(author_url  => $dom, '[itemprop="author"] [itemprop="email"]');

  $self->_val(
    description => $dom,
    'meta[property="og:description"]', 'meta[name="twitter:description"]', 'meta[name="description"]'
  );

  $self->_val(
    thumbnail_url => $dom,
    'meta[property="og:image"]', 'meta[property="og:image:url"]', 'meta[name="twitter:image"]',
  );

  $self->_val(thumbnail_height => $dom, 'meta[property="og:image:height"]');
  $self->_val(thumbnail_width  => $dom, 'meta[property="og:image:width"]');
  $self->_val(provider_name    => $dom, 'meta[property="og:site_name"]', 'meta[property="twitter:site"]');

  $self->_val(title => $dom, 'meta[property="og:title"]', 'meta[name="twitter:title"]', 'title');

  $self->_val(url => $dom, 'meta[property="og:url"]', 'meta[name="twitter:url"]');
}

sub _learn_from_url {
  my $self = shift;
  my $path = $self->url->path;

  $self->title(@$path ? $path->[-1] : 'Image');

  return $self;
}

sub _val {
  my ($self, $attr, $dom, @sel) = @_;

  for (@sel) {
    my $e = $dom->at($_) or next;
    my $val = trim($e->{content} || $e->{value} || $e->{href} || $e->text || '') or next;
    $val = Mojo::URL->new($val) if $attr eq 'url';
    return $self->$attr($val);
  }
}

1;
