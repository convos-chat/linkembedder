package Mojolicious::Plugin::LinkEmbedder;

=head1 NAME

Mojolicious::Plugin::LinkEmbedder - Convert a URL to embedded content

=head1 VERSION

0.16

=head1 DESCRIPTION

This module can transform a URL to an iframe, image or other embeddable
content.

=head1 SYNOPSIS

  use Mojolicious::Lite;
  plugin LinkEmbedder => { route => '/embed' };

Or if you want full control:

  plugin 'LinkEmbedder';
  get '/embed' => sub {
    my $self = shift->render_later;

    $self->embed_link($self->param('url'), sub {
      my($self, $link) = @_;

      $self->respond_to(
        json => {
          json => {
            media_id => $link->media_id,
            url => $link->url->to_string,
          },
        },
        any => { text => $link->to_embed },
      );
    });
  };

  app->start;

=head1 SUPPORTED LINKS

=over 4

=item * L<Mojolicious::Plugin::LinkEmbedder::Link>

=item * L<Mojolicious::Plugin::LinkEmbedder::Link::Game::_2play>

=item * L<Mojolicious::Plugin::LinkEmbedder::Link::Image>

=item * L<Mojolicious::Plugin::LinkEmbedder::Link::Image::Imgur>

=item * L<Mojolicious::Plugin::LinkEmbedder::Link::Image::Xkcd>

=item * L<Mojolicious::Plugin::LinkEmbedder::Link::Video>

=item * L<Mojolicious::Plugin::LinkEmbedder::Link::Video::Dbtv>

=item * L<Mojolicious::Plugin::LinkEmbedder::Link::Video::Blip>

=item * L<Mojolicious::Plugin::LinkEmbedder::Link::Video::Collegehumor>

=item * L<Mojolicious::Plugin::LinkEmbedder::Link::Video::Dagbladet>

=item * L<Mojolicious::Plugin::LinkEmbedder::Link::Video::Ted>

=item * L<Mojolicious::Plugin::LinkEmbedder::Link::Video::Vimeo>

=item * L<Mojolicious::Plugin::LinkEmbedder::Link::Video::Youtube>

=item * L<Mojolicious::Plugin::LinkEmbedder::Link::Text>

=item * L<Mojolicious::Plugin::LinkEmbedder::Link::Text::HTML>

=item * L<Mojolicious::Plugin::LinkEmbedder::Link::Text::Github>

=item * L<Mojolicious::Plugin::LinkEmbedder::Link::Text::GistGithub>

=item * L<Mojolicious::Plugin::LinkEmbedder::Link::Text::Metacpan>

=item * L<Mojolicious::Plugin::LinkEmbedder::Link::Text::Twitter>

=back

=cut

use Mojo::Base 'Mojolicious::Plugin';
use Mojo::Cache;
use Mojo::JSON;
use Mojo::Loader;
use Mojo::UserAgent;
use Mojolicious::Plugin::LinkEmbedder::Link;
use constant DEBUG => $ENV{MOJO_LINKEMBEDDER_DEBUG} || 0;

our $VERSION = '0.16';
my $LOADER = Mojo::Loader->new;

=head1 ATTRIBUTES

=head2 cache_cb

Holds a callback which will cache the results form the Link objects. An example
of such an callback could be:

  my %CACHE;
  $self->cache_cb(
    sub {
      my $cb = pop;
      my ($self, $url, $link) = @_;

      if ($link) { # set
        $CACHE{$url} = Mojo::JSON::encode_json($link);
        $self->$cb;
      }
      else { # get
        $self->$cb(Mojo::JSON::decode_json($CACHE{$url} || '{}'));
      }
    }
  );

=cut

has cache_cb => sub {
  return sub {
    my $cb = pop;
    my ($self, $url, $link) = @_;

    if ($link) {
      warn "SET $url\n" if DEBUG;
      $self->_cache->set($url => Mojo::JSON::encode_json($link));
      $self->$cb;
    }
    else {
      warn "GET $url --- ", $self->_cache->get($url) || 'false', "\n" if DEBUG;
      $self->$cb(Mojo::JSON::decode_json($self->_cache->get($url) || '{}'));
    }
  };
};

has _cache => sub { Mojo::Cache->new(keys => 200); };
has _ua => sub { Mojo::UserAgent->new(max_redirects => 3) };

=head1 METHODS

=head2 embed_link

See L</SYNOPSIS>.

=cut

sub embed_link {
  my ($self, $c, $url, $cb) = @_;

  if ($url =~ m!\.(?:jpg|png|gif)\b!i) {
    return $c if $self->_new_link_object(image => $c, {url => $url}, $cb);
  }
  if ($url =~ m!\.(?:mpg|mpeg|mov|mp4|ogv)\b!i) {
    return $c if $self->_new_link_object(video => $c, {url => $url}, $cb);
  }

  Scalar::Util::weaken($self);
  $self->cache_cb->(
    $self, $url,
    sub {
      my ($self, $data) = @_;
      return $self->_new_link_object(undef => $c, $data, $cb) if $data and defined $data->{media_id};
      return $self->_ua->head($url, sub { $_[1]->{input_url} = $url; $self->_learn($c, $_[1], $cb) });
    }
  );

  return $c;
}

sub _learn {
  my ($self, $c, $tx, $cb) = @_;
  my $ct = $tx->res->headers->content_type || '';
  my $url = $tx->req->url;

  return if $ct =~ m!^image/!     and $self->_new_link_object(image => $c, {url => $url, _tx => $tx}, $cb);
  return if $ct =~ m!^video/!     and $self->_new_link_object(video => $c, {url => $url, _tx => $tx}, $cb);
  return if $ct =~ m!^text/plain! and $self->_new_link_object(text  => $c, {url => $url, _tx => $tx}, $cb);

  if (my $type = lc $url->host) {
    $type =~ s/^(?:www|my)\.//;
    $type =~ s/\.\w+$//;
    return if $self->_new_link_object($type => $c, {url => $url, _tx => $tx}, $cb);
  }
  if ($ct =~ m!^text/html!) {
    return if $self->_new_link_object(html => $c, {url => $url, _tx => $tx}, $cb);
  }

  warn "[LINK] New from $ct: Mojolicious::Plugin::LinkEmbedder::Link\n" if DEBUG;
  $c->$cb(Mojolicious::Plugin::LinkEmbedder::Link->new(url => $url));
}

sub _new_link_object {
  my ($self, $type, $c, $args, $cb) = @_;
  my $class = $self->{classes}{$type} || $args->{class} || return;
  my $e = $LOADER->load($class);

  warn "[LINK] New from $type: $class\n" if DEBUG;
  local $args->{ua} = $self->_ua;

  if ($args->{url} and !ref $args->{url}) {
    $args->{url} = Mojo::URL->new($args->{url});
  }

  if (!defined $e) {
    my $link = $class->new($args);

    if (defined $link->{media_id}) {    # loaded from cache
      $c->$cb($link);
      return $class;
    }

    Mojo::IOLoop->delay(
      sub {
        my ($delay) = @_;
        $link->learn($c, $delay->begin);
      },
      sub {
        my ($delay) = @_;
        return $delay->pass unless $args->{_tx}{input_url};
        return $self->cache_cb->($self, $args->{_tx}{input_url}, $link, $delay->begin);
      },
      sub {
        my ($delay) = @_;
        $c->$cb($link);
      },
    );

    return $class;
  }

  die $e if ref $e;
  return;
}

=head2 register

  $app->plugin('LinkEmbedder' => \%config);

Will register the L</embed_link> helper which creates new objects from
L<Mojolicious::Plugin::LinkEmbedder::Default>. C<%config> is optional but can
contain:

=over 4

=item * route => $str|$obj

Use this if you want to have the default handler to do link embedding.
The default handler is shown in L</SYNOPSIS>. C<$str> is just a path,
while C<$obj> is a L<Mojolicious::Routes::Route> object.

=back

=cut

sub register {
  my ($self, $app, $config) = @_;

  $self->{classes} = {
    '2play'        => 'Mojolicious::Plugin::LinkEmbedder::Link::Game::_2play',
    'beta.dbtv'    => 'Mojolicious::Plugin::LinkEmbedder::Link::Video::Dbtv',
    'dbtv'         => 'Mojolicious::Plugin::LinkEmbedder::Link::Video::Dbtv',
    'blip'         => 'Mojolicious::Plugin::LinkEmbedder::Link::Video::Blip',
    'collegehumor' => 'Mojolicious::Plugin::LinkEmbedder::Link::Video::Collegehumor',
    'gist.github'  => 'Mojolicious::Plugin::LinkEmbedder::Link::Text::GistGithub',
    'github'       => 'Mojolicious::Plugin::LinkEmbedder::Link::Text::Github',
    'html'         => 'Mojolicious::Plugin::LinkEmbedder::Link::Text::HTML',
    'image'        => 'Mojolicious::Plugin::LinkEmbedder::Link::Image',
    'imgur'        => 'Mojolicious::Plugin::LinkEmbedder::Link::Image::Imgur',
    'metacpan'     => 'Mojolicious::Plugin::LinkEmbedder::Link::Text::Metacpan',
    'ted'          => 'Mojolicious::Plugin::LinkEmbedder::Link::Video::Ted',
    'text'         => 'Mojolicious::Plugin::LinkEmbedder::Link::Text',
    'twitter'      => 'Mojolicious::Plugin::LinkEmbedder::Link::Text::Twitter',
    'video'        => 'Mojolicious::Plugin::LinkEmbedder::Link::Video',
    'vimeo'        => 'Mojolicious::Plugin::LinkEmbedder::Link::Video::Vimeo',
    'youtube'      => 'Mojolicious::Plugin::LinkEmbedder::Link::Video::Youtube',
    'xkcd'         => 'Mojolicious::Plugin::LinkEmbedder::Link::Image::Xkcd',
  };

  $app->helper(
    embed_link => sub {
      return $self if @_ == 1;
      return $self->embed_link(@_);
    }
  );

  if (my $route = $config->{route}) {
    $self->_add_action($app, $route);
  }
  if (my $cb = $config->{cache_cb}) {
    $self->cache_cb($cb);
  }
}

sub _add_action {
  my ($self, $app, $route) = @_;

  unless (ref $route) {
    $route = $app->routes->route($route);
  }

  $route->to(
    cb => sub {
      my $c = shift->render_later;

      $c->embed_link(
        $c->param('url'),
        sub {
          my ($c, $link) = @_;

          $c->respond_to(json => {json => $link}, any => {text => $link->to_embed},);
        }
      );
    }
  );
}

=head1 DISCLAIMER

This module might embed javascript from 3rd party services.

Any damage caused by either evil DNS takeover or malicious code inside
the javascript is not taken into account by this module.

If you are aware of any security risks, then please let us know.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014, Jan Henning Thorsen

This program is free software, you can redistribute it and/or modify
it under the terms of the Artistic License version 2.0.

=head1 AUTHOR

Jan Henning Thorsen - C<jhthorsen@cpan.org>

Joel Berger, jberger@cpan.org

Marcus Ramberg - C<mramberg@cpan.org>

=cut

1;
