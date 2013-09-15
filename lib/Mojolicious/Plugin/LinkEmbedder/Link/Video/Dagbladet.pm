package Mojolicious::Plugin::LinkEmbedder::Link::Video::Dagbladet;

=head1 NAME

Mojolicious::Plugin::LinkEmbedder::Link::Video::Dagbladet - dagbladet.no link

=head1 DESCRIPTION

This class inherit from L<Mojolicious::Plugin::LinkEmbedder::Link::Video>.

=cut

use Mojo::Base 'Mojolicious::Plugin::LinkEmbedder::Link::Video';

=head1 ATTRIBUTES

=head2 media_id

Returns the the digit from the second path part from L</url>.

=cut

has media_id => sub { shift->url->query->param('clipid') };

=head1 METHODS

=head2 to_embed

Returns the HTML code for an iframe embedding this movie.

=cut

sub to_embed {
  my $self = shift;
  my $src = Mojo::URL->new('http://www.dagbladet.no/tv/videospiller/player_v2_embed.php');
  my %args = @_;

  $args{height} ||= 288;
  $args{width} ||= 512;

  $src->query({
    id => $self->media_id,
    w => $args{width},
    h => $args{height},
    autoplay => $args{autoplay} || 0,
    playerBorder => 0,
  });

  qq(<iframe src="$src" width="$args{width}" height="$args{height}" frameborder="0" marginheight="0" marginwidth="0" scrolling="no"></iframe>);
}

=head1 AUTHOR

Marcus Ramberg

=cut

1;
