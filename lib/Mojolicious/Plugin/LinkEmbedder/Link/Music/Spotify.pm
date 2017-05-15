package Mojolicious::Plugin::LinkEmbedder::Link::Music::Spotify;
use Mojo::Base 'Mojolicious::Plugin::LinkEmbedder::Link::Music';

has media_id => sub {
  my $self = shift;
  my $path = $self->url->path;

  return join ':', spotify => "$path" if $self->url->scheme eq 'spotify';
  return join ':', spotify => @$path  if @$path == 2;
  return '';
};

sub provider_name {'Spotify'}

sub pretty_url {
  my $self     = shift;
  my $url      = Mojo::URL->new('https://open.spotify.com');
  my $media_id = $self->media_id;

  $media_id =~ s!^spotify!!;
  $url->path(join '/', split ':', $media_id);
  $url;
}

sub to_embed {
  my $self     = shift;
  my $media_id = $self->media_id or return $self->SUPER::to_embed;
  my %args     = @_;

  $args{width}  ||= 300;
  $args{height} ||= 80;
  $args{view}   ||= 'coverart';
  $args{theme}  ||= 'white';

  $self->_iframe(
    src    => "https://embed.spotify.com/?uri=$media_id&theme=$args{theme}&view=$args{view}",
    class  => 'link-embedder music-spotify',
    width  => $args{width},
    height => $args{height}
  );
}

1;
