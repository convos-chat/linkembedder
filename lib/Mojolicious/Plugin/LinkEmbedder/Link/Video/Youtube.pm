package Mojolicious::Plugin::LinkEmbedder::Link::Video::Youtube;

=head1 NAME

Mojolicious::Plugin::LinkEmbedder::Link::Video::Youtube - youtube.com link

=head1 DESCRIPTION

L<https://developers.google.com/youtube/player_parameters#Embedding_a_Player>

This class inherit from L<Mojolicious::Plugin::LinkEmbedder::Link::Video>.

=cut

use Mojo::Base 'Mojolicious::Plugin::LinkEmbedder::Link::Video';

=head1 ATTRIBUTES

=head2 media_id

Returns the "v" query param value from L</url>.

=cut

has media_id => sub { shift->url->query->param('v') || '' };

=head1 METHODS

=head2 pretty_url

Returns L</url> without "eurl", "mode" and "search" query params.

=cut

sub pretty_url {
  my $self  = shift;
  my $url   = $self->url->clone;
  my $query = $url->query;

  $query->remove('eurl');
  $query->remove('mode');
  $query->remove('search');
  $url;
}

=head2 to_embed

Returns the HTML code for an iframe embedding this movie.

=cut

sub to_embed {
  my $self     = shift;
  my $media_id = $self->media_id or return $self->SUPER::to_embed;
  my $url      = Mojo::URL->new("http://www.youtube.com/embed/$media_id");
  my %args     = @_;

  $url->query->param(autoplay => 1) if $args{autoplay};

  $args{width}  ||= $self->DEFAULT_VIDEO_WIDTH;
  $args{height} ||= $self->DEFAULT_VIDEO_HEIGHT;

  qq(<iframe width="$args{width}" height="$args{height}" src="$url">);
}

=head1 AUTHOR

Marcus Ramberg

=cut

1;
