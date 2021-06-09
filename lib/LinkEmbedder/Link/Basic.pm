package LinkEmbedder::Link::Basic;
use Mojo::Base 'LinkEmbedder::Link';

use Mojo::JSON;
use Mojo::Util 'trim';

my $PHOTO_RE = qr!\.(?:jpg|png|gif|webp)\b!i;
my $VIDEO_RE = qr!\.(?:mpg|mpeg|mov|mp4|ogv|webm)\b!i;

sub learn_p {
  my $self = shift;
  my $url  = $self->url;
  my $type = $url =~ $PHOTO_RE ? 'photo' : $url =~ $VIDEO_RE ? 'video' : 'link';

  $self->type($type);

  if ($type eq 'video' and $url =~ m/\.([^.]+)$/) {
    $self->mimetype(lc "video/$1");
  }

  return $type eq 'link' ? $self->SUPER::learn_p : Mojo::Promise->new->resolve($self->_learn_from_url);
}

sub _learn_from_dom {
  my ($self, $dom) = @_;
  my $tmp;

  $self->SUPER::_learn_from_dom($dom);

  $tmp = $dom->at('script[type="application/ld+json"]');
  $self->_learn_from_json_schema($tmp->text) if $tmp;

  # Bitbucket hack
  $tmp = $dom->at('div.codehilite');
  if ($tmp) {
    $self->{paste} = $tmp->all_text;
    $self->template->[1] = 'paste.html.ep';
  }

  # Mojopaste, Perlbot and other pages with <pre> tags
  if ($tmp = $dom->at('pre#paste') || $dom->at('pre.paste') || $dom->at('body > pre') || $dom->at('body > div > pre') || $dom->at('.code')) {
    $self->{paste} = $tmp->all_text;
    $self->template->[1] = 'paste.html.ep';
  }

  # centos paste
  $tmp = $dom->at('textarea#code');
  if ($tmp and !@{$tmp->children}) {
    $self->{paste} = $tmp->text;
    $self->template->[1] = 'paste.html.ep';
  }

  $tmp = $dom->at('.author-pic > a > img') || $dom->at('link[rel="apple-touch-icon"]') || $dom->at('[rel="icon"]');
  if (!$self->thumbnail_url and $tmp and $tmp->{src} ||= $tmp->{href}) {
    $self->thumbnail_url(Mojo::URL->new($tmp->{src})->to_abs(Mojo::URL->new($self->url))->to_string);
  }

  $tmp = $dom->at('p.about');
  if (!$self->description and $tmp) {
    $tmp = $tmp->all_text;
    $tmp =~ s!\s+! !g;
    $self->description(trim $tmp);
  }

  return $self;
}

sub _learn_from_json_schema {
  my ($self, $json) = @_;
  eval { $json = Mojo::JSON::from_json($json) } unless ref $json eq 'HASH';
  return                                        unless ref $json eq 'HASH';

  my $author = ref $json->{author} eq 'ARRAY' ? $json->{author}[0] : $json->{author};
  $self->author_name($author->{name})      if ref $author eq 'HASH' and $author->{name};
  $self->description($json->{description}) if $json->{description};
  $self->title($json->{headline})          if $json->{headline};
}

1;
