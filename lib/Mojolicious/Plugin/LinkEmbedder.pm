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

=item * L<Mojolicious::Plugin::LinkEmbedder::Fallback>

=item * L<Mojolicious::Plugin::LinkEmbedder::Image>

=item * L<Mojolicious::Plugin::LinkEmbedder::Video>

=item * L<Mojolicious::Plugin::LinkEmbedder::Youtube>

=back

=cut

use Mojo::Base 'Mojolicious::Plugin';
use Mojo::UserAgent;

our $VERSION = '0.01';

has _ua => sub { Mojo::UserAgent->new };

=head1 METHODS

=head2 embed_link

See L</SYNOPSIS>.

=cut

sub embed_link {
  my($self, $c, $url, $cb) = @_;
  my $type;

  $url = Mojo::URL->new($url) unless ref $url;

  if(my $type = $url->host) {
    $type =~ s/^(?:www|my)\.//;
    $type =~ s/\.\w+$//;
    $type =~ s/\.(\w+)/{ ucfirst $1 }/ge;
    $type =~ s/^(\d+)/_$1/;
    $self->_new_link(ucfirst $type, $c, $url, $cb) and return $c;
  }

  if($url->path =~ m!\.(?:jpg|png|gif)$!i) {
    $self->_new_link('Image', $c, $url, $cb) and return $c;
  }

  if($url->path =~ m!\.(?:mpg|mpeg|mov|mp4|ogv)$!i) {
    $self->_new_link('Video', $c, $url, $cb) and return $c;
  }

  $self->_ua->head($url, sub {
    my($ua, $tx) = @_;
    my $ct = $tx->res->headers->content_type || '';
    return $self->_new_link('Image', $c, $url, $cb) if $ct =~ m!^image/!;
    return $self->_new_link('Video', $c, $url, $cb) if $ct =~ m!^video/!;
    return $self->_new_link('Fallback', $c, $url, $cb);
  });

  return $c;
}

sub _new_link {
  my($self, $type, $c, $url, $cb) = @_;
  my $class = "Mojolicious::Plugin::LinkEmbedder::$type";

  if(eval "require $class; 1") {
    $c->$cb($class->new(url => $url));
    return 1;
  }
  else {
    warn "LinkEmbedder($type): $@" unless $@ =~ /^Can't locate/i;
    return 0;
  }
}

=head2 register

Will register the L</embed_link> helper which creates new objects from
L<Mojolicious::Plugin::LinkEmbedder::Default>.

=cut

sub register {
  my($self, $app, $config) = @_;

  $app->helper(embed_link => sub { $self->embed_link(@_) });
}

=head1 AUTHOR

Jan Henning Thorsen - C<jhthorsen@cpan.org>

Marcus Ramberg - C<mramberg@cpan.org>

=cut

1;
