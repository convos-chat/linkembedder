package Mojolicious::Plugin::LinkEmbedder::Link::Video::Vimeo;

=head1 NAME

Mojolicious::Plugin::LinkEmbedder::Link::Video::Vimeo - vimeo.com video

=head1 DESCRIPTION

This class inherit from L<Mojolicious::Plugin::LinkEmbedder::Link::Video>.

=cut

use Mojo::Base 'Mojolicious::Plugin::LinkEmbedder::Link::Video';

=head1 ATTRIBUTES

=head2 media_id

Returns the the digit from the url L</url>.

=cut

has media_id => sub {
  my $self = shift;
  my $media_id = $self->url->path->[-1];

  $media_id =~ s!\.html$!!;
  $media_id;
};

=head1 METHODS

=head2 to_embed

Returns the HTML code for an iframe embedding this movie.

=cut

sub to_embed {
  my $self = shift;
  my $src = Mojo::URL->new('//player.vimeo.com/video/86404451?portrait=0&amp;color=ffffff');
  my $media_id = $self->media_id;
  my %args = @_;

  $args{height} ||= 281;
  $args{width} ||= 500;

  qq(<iframe src="//player.vimeo.com/video/$media_id?portrait=0&amp;color=ffffff" width="$args{width}" height="$args{height}" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>);
}

=head1 AUTHOR

Marcus Ramberg

=cut

1;
