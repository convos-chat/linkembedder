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
    'default'            => 'LinkEmbedder::Link::Basic',
    'appear.in'          => 'LinkEmbedder::Link::AppearIn',
    'git.io'             => 'LinkEmbedder::Link::Github',
    'github.com'         => 'LinkEmbedder::Link::Github',
    'google'             => 'LinkEmbedder::Link::Google',
    'imgur.com'          => 'LinkEmbedder::Link::Imgur',
    'ix.io'              => 'LinkEmbedder::Link::Ix',
    'instagram.com'      => 'LinkEmbedder::Link::oEmbed',
    'metacpan.org'       => 'LinkEmbedder::Link::Metacpan',
    'paste.opensuse.org' => 'LinkEmbedder::Link::OpenSUSE',
    'paste.scsys.co.uk'  => 'LinkEmbedder::Link::Shadowcat',
    'pastebin.com'       => 'LinkEmbedder::Link::Pastebin',
    'spotify'            => 'LinkEmbedder::Link::Spotify',
    'ted.com'            => 'LinkEmbedder::Link::oEmbed',
    'travis-ci.org'      => 'LinkEmbedder::Link::Travis',
    'twitter.com'        => 'LinkEmbedder::Link::Twitter',
    'vimeo.com'          => 'LinkEmbedder::Link::oEmbed',
    'xkcd.com'           => 'LinkEmbedder::Link::Xkcd',
    'youtube.com'        => 'LinkEmbedder::Link::oEmbed',
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

  $link ||= _host_in_hash($args->{url}->host, $self->url_to_link);
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

sub _host_in_hash {
  my ($host, $hash) = @_;
  return $hash->{$host} if $hash->{$host};

  $host = $1 if $host =~ m!([^\.]+\.\w+)$!;
  return $hash->{$host} if $hash->{$host};

  $host = $1 if $host =~ m!([^\.]+)\.\w+$!;
  return $hash->{$host} || $hash->{default};
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

1;

=encoding utf8

=head1 NAME

LinkEmbedder - Embed / expand oEmbed resources and other URL / links

=head1 SYNOPSIS

  use LinkEmbedder;

  my $embedder = LinkEmbedder->new;
  my $link     = $embedder->get("http://xkcd.com/927");
  print $link->html;

=head1 DESCRIPTION

L<LinkEmbedder> is module which can be used to expand an URL into a rich HTML
snippet or simply to extract information about the URL.

Note that this module is currently EXPERIMENTAL. It will replace
L<Mojolicious::Plugin::LinkEmbedder> once it gets stable.

These web pages are currently supported:

=over 2

=item * L<http://imgur.com/>

=item * L<https://instagram.com/>

=item * L<https://appear.in/>

=item * L<https://github.com>

=item * L<https://ix.io>

=item * L<https://maps.google.com>

=item * L<https://metacpan.org>

=item * L<http://paste.opensuse.org>

=item * L<http://paste.scsys.co.uk>

=item * L<http://pastebin.com>

=item * L<https://www.spotify.com/>

=item * L<https://ted.com>

=item * L<https://travis-ci.org>

=item * L<https://twitter.com>

=item * L<https://vimeo.com>

=item * L<https://youtube.com>

=item * L<https://www.xkcd.com/>

=item * HTML

Any web page will be parsed, and "og:", "twitter:", meta tags and other
significant elements will be used to generate a oEmbed response.

=item * Images

URLs that looks like an image is automatically converted into an img tag.

=item * Video

URLs that looks like a video resource is automatically converted into a video tag.

=back

=head1 ATTRIBUTES

=head2 ua

  $ua = $self->ua;

Holds a L<Mojo::UserAgent> object.

=head2 url_to_link

  $hash_ref = $self->url_to_link;

Holds a mapping between host names and L<link class|LinkEmbedder::Link> to use.

=head1 METHODS

=head2 get

  $self = $self->get($url, sub { my ($self, $link) = @_; });
  $link = $self->get($url);

Used to construct a new L<LinkEmbedder::Link> object and retrieve information
about the URL.

=head2 serve

  $self = $self->serve(Mojolicious::Controller->new, $url);

Used as a helper for L<Mojolicious> web applications to reply to an oEmbed
request.

=head1 AUTHOR

Jan Henning Thorsen

=head1 COPYRIGHT AND LICENSE

This program is free software, you can redistribute it and/or modify it under
the terms of the Artistic License version 2.0.

=cut
