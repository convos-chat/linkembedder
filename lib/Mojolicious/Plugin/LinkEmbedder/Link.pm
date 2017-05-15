package Mojolicious::Plugin::LinkEmbedder::Link;
use Mojo::Base -base;
use Mojo::ByteStream;
use Mojo::Util 'xml_escape';
use Mojolicious::Types;
use Scalar::Util 'blessed';

# this may change in future version
use constant DEFAULT_VIDEO_HEIGHT => 390;
use constant DEFAULT_VIDEO_WIDTH  => 640;

has author_name => '';
has author_url  => '';
has error       => undef;
has etag        => sub {
  eval { shift->_tx->res->headers->etag } // '';
};

has media_id      => '';
has provider_name => sub { ucfirst shift->url->host };
has provider_url  => sub {
  my $self = shift;
  return Mojo::URL->new(host => $self->url->host, scheme => $self->url->scheme);
};

has title => '';
has ua    => sub { die "Required in constructor" };
has url   => sub { shift->_tx->req->url };

# should this be public?
has _tx => undef;

has _types => sub {
  my $types = Mojolicious::Types->new;
  $types->type(mpg  => 'video/mpeg');
  $types->type(mpeg => 'video/mpeg');
  $types->type(mov  => 'video/quicktime');
  $types;
};

sub is {
  $_[0]->isa(__PACKAGE__ . '::' . Mojo::Util::camelize($_[1]));
}

sub learn {
  my ($self, $c, $cb) = @_;
  $self->$cb;
  $self;
}

sub pretty_url { shift->url->clone }

sub tag {
  my $self = shift;
  my $name = shift;

  # Content
  my $cb = ref $_[-1] eq 'CODE' ? pop : undef;
  my $content = @_ % 2 ? pop : undef;

  # Start tag
  my $tag = "<$name";

  # Attributes
  my %attrs = @_;
  if ($attrs{data} && ref $attrs{data} eq 'HASH') {
    while (my ($key, $value) = each %{$attrs{data}}) {
      $key =~ y/_/-/;
      $attrs{lc("data-$key")} = $value;
    }
    delete $attrs{data};
  }

  for my $k (sort keys %attrs) {
    $tag .= defined $attrs{$k} ? qq{ $k="} . xml_escape($attrs{$k} // '') . '"' : " $k";
  }

  # Empty element
  unless ($cb || defined $content) { $tag .= '>' }

  # End tag
  else { $tag .= '>' . ($cb ? $cb->() : xml_escape $content) . "</$name>" }

  # Prevent escaping
  return Mojo::ByteStream->new($tag);
}

sub to_embed {
  my $self = shift;
  my $url  = $self->url;
  my @args;

  return sprintf '<a href="#">%s</a>', $self->provider_name unless $url->host;

  push @args, target => '_blank';
  push @args, title => "Content-Type: @{[$self->_tx->res->headers->content_type]}" if $self->_tx;

  return $self->tag(a => (href => $url, @args), sub {$url});
}

# Mojo::JSON will automatically filter out ua and similar objects
sub TO_JSON {
  my $self = shift;
  my $url  = $self->url;

  return {
    # oembed
    # cache_age => 86400,
    # height => $self->DEFAULT_VIDEO_HEIGHT,
    # version => '1.0', # not really 1.0...
    # width => $self->DEFAULT_VIDEO_WIDTH,
    author_name   => $self->author_name,
    author_url    => $self->author_url,
    html          => $self->to_embed,
    provider_name => $self->provider_name,
    provider_url  => $self->provider_url,
    title         => $self->title,
    type          => 'rich',
    url           => $url,

    # extra
    pretty_url => $self->pretty_url,
    media_id   => $self->media_id,
  };
}

sub _iframe {
  shift->tag(
    iframe                => frameborder => 0,
    allowfullscreen       => undef,
    webkitAllowFullScreen => undef,
    mozallowfullscreen    => undef,
    scrolling             => 'no',
    class                 => 'link-embedder',
    @_, 'Your browser is super old.',
  );
}

1;
