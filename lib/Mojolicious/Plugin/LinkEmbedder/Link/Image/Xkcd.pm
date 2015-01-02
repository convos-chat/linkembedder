package Mojolicious::Plugin::LinkEmbedder::Link::Image::Xkcd;

=head1 NAME

Mojolicious::Plugin::LinkEmbedder::Link::Image::Xkcd - xkcd.com image/comic

=head1 DESCRIPTION

This class inherits from L<Mojolicious::Plugin::LinkEmbedder::Link::Image>.

=cut

use Mojo::Base 'Mojolicious::Plugin::LinkEmbedder::Link::Image';

use Mojo::URL;
use Mojo::IOLoop;

=head1 ATTRIBUTES

=head2 actual_link

The C<img> link extracted from the retrieved page

=head2 media_id

Extracts the media_id from the url directly

=cut

has media_id => sub { shift->url->path->[0] };

=head2 media_url

URL to the image itself, extracted from the retrieved page

=head2 media_title

The title of the image, extracted from the retrieved page

=head2 media_hover_text

The secret part of xkcd jokes

=cut

has [qw/actual_link media_url media_title media_hover_text/];

=head1 METHODS

=head2 learn

Gets the file imformation from the page meta information

=cut

sub learn {
  my ($self, $c, $cb) = @_;
  my $ua    = $self->{ua};
  my $delay = Mojo::IOLoop->delay(
    sub {
      my $delay = shift;
      $ua->get($self->url, $delay->begin);
    },
    sub {
      my ($ua, $tx) = @_;
      my $link = $tx->res->dom->at('#comic img');
      $self->actual_link($link ? "$link" : '');
      $link ||= {};
      $self->media_url(Mojo::URL->new($link->{src})) if $link->{src};
      $self->media_title($link->{alt});
      $self->media_hover_text($link->{title});
      $self->$cb;
    },
  );
  $delay->wait unless $delay->ioloop->is_running;
}

=head2 to_embed

Returns the C<actual_link> extracted from the xkcd site

=cut

sub to_embed { shift->actual_link }

=head1 AUTHOR

Joel Berger - C<jberger@cpan.org>

=cut

1;
