package Mojolicious::Plugin::LinkEmbedder::Link::Game::_2play;
use Mojo::Base 'Mojolicious::Plugin::LinkEmbedder::Link::Game';

has media_id => sub { shift->url->path->[2] || '' };
sub provider_name {'2play'}
sub _js_embed_url {'http://video.nettavisen.no/javascripts/embed.js'}

sub to_embed {
  my $self = shift;
  my $media_id = $self->media_id or return $self->SUPER::to_embed;

  qq(<script src="@{[$self->_js_embed_url]}"></script><script>video_embed("$media_id",1)</script>);
}

1;
