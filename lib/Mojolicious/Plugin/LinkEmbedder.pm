package Mojolicious::Plugin::LinkEmbedder;

=head1 NAME

Mojolicious::Plugin::LinkEmbedder - Convert a URL to embedded content

=head1 VERSION

0.01

=head1 DESCRIPTION

This module can transform a URL to an iframe, image or other embeddable
content.

=head1 SYNOPSIS

  use Mojolicious::Lite;
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
        any => { text => "$link" },
      );
    });
  };

  app->start;

=head1 SUPPORTED LINKS

=over 4

=item * L<Mojolicious::Plugin::LinkEmbedder::Link>

=item * L<Mojolicious::Plugin::LinkEmbedder::Link::Game::_2play>

=item * L<Mojolicious::Plugin::LinkEmbedder::Link::Image>

=item * L<Mojolicious::Plugin::LinkEmbedder::Link::Video>

=item * L<Mojolicious::Plugin::LinkEmbedder::Link::Video::Blip>

=item * L<Mojolicious::Plugin::LinkEmbedder::Link::Video::Collegehumor>

=item * L<Mojolicious::Plugin::LinkEmbedder::Link::Video::Dagbladet>

=item * L<Mojolicious::Plugin::LinkEmbedder::Link::Video::Ted>

=item * L<Mojolicious::Plugin::LinkEmbedder::Link::Video::Vimeo>

=item * L<Mojolicious::Plugin::LinkEmbedder::Link::Video::Youtube>

=item * L<Mojolicious::Plugin::LinkEmbedder::Link::Text>

=item * L<Mojolicious::Plugin::LinkEmbedder::Link::Text::GistGithub>

=item * L<Mojolicious::Plugin::LinkEmbedder::Link::Text::Twitter>

=back

=cut

use Mojo::Base 'Mojolicious::Plugin';
use Mojo::Loader;
use Mojo::UserAgent;
use Mojolicious::Plugin::LinkEmbedder::Link;
use constant DEBUG => $ENV{MOJO_LINKEMBEDDER_DEBUG} || 0;

our $VERSION = '0.01';
my $LOADER = Mojo::Loader->new;

has _ua => sub { Mojo::UserAgent->new };

=head1 METHODS

=head2 embed_link

See L</SYNOPSIS>.

=cut

sub embed_link {
  my($self, $c, $url, $cb) = @_;
  my $type;

  $url = Mojo::URL->new($url) unless ref $url;

  if(my $type = lc $url->host) {
    $type =~ s/^(?:www|my)\.//;
    $type =~ s/\.\w+$//;
    return $c if $self->_new_link_object($type => $c, { url => $url }, $cb);
  }

  if($url->path =~ m!\.(?:jpg|png|gif)$!i) {
    return $c if $self->_new_link_object(image => $c, { url => $url }, $cb);
  }

  if($url->path =~ m!\.(?:mpg|mpeg|mov|mp4|ogv)$!i) {
    return $c if $self->_new_link_object(video => $c, { url => $url }, $cb);
  }

  $self->_ua->head($url, sub {
    my($ua, $tx) = @_;
    my $ct = $tx->res->headers->content_type || '';
    return $self->_new_link_object(image => $c, { url => $url, _tx => $tx }, $cb) if $ct =~ m!^image/!;
    return $self->_new_link_object(video => $c, { url => $url, _tx => $tx }, $cb) if $ct =~ m!^video/!;
    return $self->_new_link_object(text => $c, { url => $url, _tx => $tx }, $cb) if $ct =~ m!^text/plain!;
    return $c->$cb(Mojolicious::Plugin::LinkEmbedder::Link->new(url => $url));
  });

  return $c;
}

sub _new_link_object {
  my($self, $type, $c, $args, $cb) = @_;
  my $class = $self->{classes}{$type} || '';
  my $e = $LOADER->load($class);

  warn "[LINK] new from $type: $class\n" if DEBUG;

  if(!defined $e) {
    my $link = $class->new($args);
    $link->{ua} = $self->_ua;
    $link->learn($cb, $c, $link);
    return $class;
  }

  die $e if ref $e;
  return;
}

=head2 register

Will register the L</embed_link> helper which creates new objects from
L<Mojolicious::Plugin::LinkEmbedder::Default>.

=cut

sub register {
  my($self, $app, $config) = @_;

  $self->{classes} = {
    '2play' => 'Mojolicious::Plugin::LinkEmbedder::Link::Game::_2play',
    'beta.dbtv' => 'Mojolicious::Plugin::LinkEmbedder::Link::Video::Dbtv',
    'blip' => 'Mojolicious::Plugin::LinkEmbedder::Link::Video::Blip',
    'collegehumor' => 'Mojolicious::Plugin::LinkEmbedder::Link::Video::Collegehumor',
    'gist.github' => 'Mojolicious::Plugin::LinkEmbedder::Link::Text::GistGithub',
    'image' => 'Mojolicious::Plugin::LinkEmbedder::Link::Image',
    'ted' => 'Mojolicious::Plugin::LinkEmbedder::Link::Video::Ted',
    'text' => 'Mojolicious::Plugin::LinkEmbedder::Link::Text',
    'twitter' => 'Mojolicious::Plugin::LinkEmbedder::Link::Text::Twitter',
    'video' => 'Mojolicious::Plugin::LinkEmbedder::Link::Video',
    'vimeo' => 'Mojolicious::Plugin::LinkEmbedder::Link::Video::Vimeo',
    'youtube' => 'Mojolicious::Plugin::LinkEmbedder::Link::Video::Youtube',
  };

  $app->helper(embed_link => sub { $self->embed_link(@_) });
}

=head1 AUTHOR

Jan Henning Thorsen - C<jhthorsen@cpan.org>

Marcus Ramberg - C<mramberg@cpan.org>

=cut

1;
