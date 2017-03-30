package LinkEmbedder;

use Mojo::Base -base;

use LinkEmbedder::Link;
use Mojo::Loader 'load_class';
use Mojo::UserAgent;

our $VERSION = '0.01';

my $PROTOCOL_RE = qr!^(\w+):\w+!i;    # Examples: mail:, spotify:, ...

has ua => sub { Mojo::UserAgent->new->max_redirects(3); };

sub get {
  my ($self, $args, $cb) = @_;
  my ($e, $link);

  $args = ref $args eq 'HASH' ? {%$args} : {url => $args};
  $args->{url} = Mojo::URL->new($args->{url} || '') unless ref $args->{url};
  $args->{ua} = $self->ua;

  $link ||= delete $args->{class};
  $link ||= ucfirst $1 if $args->{url} =~ $PROTOCOL_RE;
  return $self->_invalid_input($args, 'Invalid URL', $cb) unless $link or $args->{url}->host;

  $link ||= $self->_url_to_link($args->{url});
  $link = $link =~ /::/ ? $link : "LinkEmbedder::Link::$link";
  return $self->_invalid_input($args, "Could not find $link", $cb) unless _load($link);
  $link = $link->new($args);

  # blocking
  return $link->learn unless $cb;

  # non-blocking
  Mojo::IOLoop->delay(sub { $link->learn(shift->begin) }, sub { $self->$cb($link) });
  return $self;
}

sub _invalid_input {
  my ($self, $args, $msg, $cb) = @_;

  $args->{error} = {message => $msg, code => 400};
  my $link = LinkEmbedder::Link->new($args);

  # blocking
  return $link unless $cb;

  # non-blocking
  Mojo::IOLoop->next_tick(sub { $self->$cb($link) });
  return $self;
}

sub _load {
  $@ = load_class $_[0];
  die $@ if ref $@;
  return $@ ? 0 : 1;
}

sub _url_to_link {
  my ($self, $url) = @_;
  return 'Basic';
}

1;
