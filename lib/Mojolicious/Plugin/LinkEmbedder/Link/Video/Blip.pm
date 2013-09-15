package Mojolicious::Plugin::LinkEmbedder::Link::Video::Blip;

=head1 NAME

Mojolicious::Plugin::LinkEmbedder::Link::Video::Blip - blip.tv link

=head1 DESCRIPTION

L<https://developers.google.com/youtube/player_parameters#Embedding_a_Player>

This class inherit from L<Mojolicious::Plugin::LinkEmbedder::Link::Video>.

=cut

use Mojo::Base 'Mojolicious::Plugin::LinkEmbedder::Link::Video';

=head1 ATTRIBUTES

=head2 media_id

Returns the second path element from L</url>.

=cut

has media_id => sub { shift->url->path->[2] || '' };

=head1 METHODS

=head2 to_embed

Returns the HTML code for an iframe embedding this movie.

=cut

sub to_embed {
  my $self = shift;
  my $src = Mojo::URL->new('http://blip.tv/scripts/flash/showplayer.swf');
  my %args = @_;

  $src->query({
    file => 'http://blip.tv/file/' .$self->media_id .'?skin=rss',
    showplayerpath => 'http://blip.tv/scripts/flash/showplayer.swf',
    feedurl => 'http://nehru.blip.tv/rss/flash',
    brandname => 'blip.tv',
    brandlink => 'http://blip.tv/?utm_source=brandlink',
    enablejs => 'true',
  });

  $args{width} ||= 425;
  $args{height} ||= 350;

  qq(<embed src="$src" type="application/x-shockwave-flash" width="$args{width}" height="$args{height}" allowscriptaccess="always" allowfullscreen="true"></embed>);
}

=head1 AUTHOR

Marcus Ramberg

=cut

1;
