package LinkEmbedder;

use Mojo::Base -base;

use LinkEmbedder::Link;
use Mojo::JSON;
use Mojo::Loader 'load_class';
use Mojo::UserAgent;

use constant DEBUG => $ENV{LINK_EMBEDDER_DEBUG} || 0;

our $VERSION = '0.01';

my $PROTOCOL_RE = qr!^(\w+):\w+!i;    # Examples: mail:, spotify:, ...

has ua => sub { Mojo::UserAgent->new->max_redirects(3); };

has url_to_link => sub {
  return {
    'imgur.com'     => 'LinkEmbedder::Link::Imgur',
    'instagram.com' => 'LinkEmbedder::Link::oEmbed',
    'xkcd.com'      => 'LinkEmbedder::Link::Xkcd'
  };
};

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
  warn "[LinkEmbedder] $link->new($args->{url})\n" if DEBUG;
  $link = $link->new($args);

  # blocking
  return $link->learn unless $cb;

  # non-blocking
  Mojo::IOLoop->delay(sub { $link->learn(shift->begin) }, sub { $self->$cb($link) });
  return $self;
}

sub serve {
  my ($self, $c, $args) = @_;
  my $format = $c->stash('format') || $c->param('format') || 'json';
  my $log_level;

  $args ||= {url => $c->param('url')};
  $log_level = delete $args->{log_level} || 'debug';

  $c->delay(
    sub { $self->get($args, shift->begin) },
    sub {
      my ($delay, $link) = @_;
      my $err = $link->error;

      $c->stash(status => $err->{code} || 500) if $err;
      return $c->render(data => $link->html) if $format eq 'html';

      my $json = $err ? {err => $err->{code} || 500} : $link->TO_JSON;
      if ($format eq 'jsonp') {
        my $cb = $c->param('callback') || 'oembed';
        $c->render(data => sprintf '%s(%s)', $cb, Mojo::JSON::to_json($json));
      }
      else {
        $c->render(json => $json);
      }
    },
  );

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
  warn "[LinkEmbedder] load $_[0]: @{[$@ || 'Success']}\n" if DEBUG;
  die $@ if ref $@;
  return $@ ? 0 : 1;
}

sub _url_to_link {
  my ($self, $url) = @_;
  my $host = $url->host;

  $host = $1 if $host =~ m!([^\.]+\.\w+)$!;
  return $self->url_to_link->{$host} || 'LinkEmbedder::Link::Basic';
}

1;
