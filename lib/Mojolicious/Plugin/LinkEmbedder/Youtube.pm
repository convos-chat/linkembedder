package Mojolicious::Plugin::LinkEmbedder::Youtube;

=head1 NAME

Mojolicious::Plugin::LinkEmbedder::YouTube - YouTube URL

=head1 DESCRIPTION

L<https://developers.google.com/youtube/player_parameters#Embedding_a_Player>

=cut

use Mojo::Base 'Mojolicious::Plugin::LinkEmbedder::Default';

=head1 ATTRIBUTES

=head2 media_id

Returns the value of the "v" param.

=cut

sub media_id {
  shift->url->query->param('v') || '';
}

=head1 METHODS

=head2 is_movie

Returns true if L</media_id> is set.

=cut

sub is_movie { shift->media_id ? 1 : 0 }

=head2 to_embed

Returns the HTML code for an iframe embedding this movie.

=cut

sub to_embed {
  my $self = shift;
  my $url = Mojo::URL->new('http://www.youtube.com/embed/' .$self->media_id);
  my %args = @_;

  $url->query->param(autoplay => 1) if delete $args{autoplay};

  $args{width} ||= 640;
  $args{height} ||= 390;

  return qq(<iframe width="$args{width}" height="$args{height}" src="$url">);
}

sub _massage_url {
  my $self = shift;
  my $url = $self->SUPER::_massage_url(shift);
  my $query = $url->query;

  $query->remove('eurl');
  $query->remove('mode');
  $query->remove('search');
  $url;
}

=head1 AUTHOR

Marcus Ramberg

=cut

1;
