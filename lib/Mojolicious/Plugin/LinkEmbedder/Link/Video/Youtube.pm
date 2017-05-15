package Mojolicious::Plugin::LinkEmbedder::Link::Video::Youtube;
use Mojo::Base 'Mojolicious::Plugin::LinkEmbedder::Link::Text::HTML';

has media_id => sub { shift->url->query->param('v') || '' };
sub provider_name {'YouTube'}

sub learn {
  my ($self, $c, $cb) = @_;

  return $self->SUPER::learn($c, $cb) unless $self->media_id;
  $self->$cb;
  $self;
}

sub pretty_url {
  my $self  = shift;
  my $url   = $self->url->clone;
  my $query = $url->query;

  $query->remove('eurl');
  $query->remove('mode');
  $query->remove('search');
  $url;
}

sub to_embed {
  my $self     = shift;
  my $media_id = $self->media_id or return $self->SUPER::to_embed;
  my $query    = Mojo::Parameters->new;
  my %args     = @_;

  $query->param(autoplay => 1) if $args{autoplay};

  $args{width}  ||= $self->DEFAULT_VIDEO_WIDTH;
  $args{height} ||= $self->DEFAULT_VIDEO_HEIGHT;

  $self->_iframe(
    src    => "//www.youtube.com/embed/$media_id?$query",
    class  => 'link-embedder video-youtube',
    width  => $args{width},
    height => $args{height}
  );
}

1;
