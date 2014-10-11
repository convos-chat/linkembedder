package Mojolicious::Plugin::LinkEmbedder::Link::Video::Collegehumor;

=head1 NAME

Mojolicious::Plugin::LinkEmbedder::Link::Video::Collegehumor - collegehumor.com link

=head1 DESCRIPTION

This class inherit from L<Mojolicious::Plugin::LinkEmbedder::Link::Video>.

=cut

use Mojo::Base 'Mojolicious::Plugin::LinkEmbedder::Link::Video';

=head1 ATTRIBUTES

=head2 media_id

Returns the the digit from the second path part from L</url>.

=cut

has media_id => sub { shift->url->path =~ m!/(\d+)/! ? $1 : '' };

=head1 METHODS

=head2 to_embed

Returns the HTML code for an iframe embedding this movie.

=cut

sub to_embed {
  my $self     = shift;
  my $media_id = $self->media_id or return $self->SUPER::to_embed;
  my $src      = Mojo::URL->new('http://www.collegehumor.com/e');
  my %args     = @_;

  push @{$src->path}, $media_id;
  $args{height} ||= 369;
  $args{width}  ||= 600;

  qq(<iframe src="$src" width="$args{width}" height="$args{height}" frameborder="0" webkitAllowFullScreen allowFullScreen></iframe>);
}

=head1 AUTHOR

Marcus Ramberg

=cut

1;
