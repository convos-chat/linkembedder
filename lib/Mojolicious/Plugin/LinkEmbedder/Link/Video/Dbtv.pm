package Mojolicious::Plugin::LinkEmbedder::Link::Video::Dbtv;
use Mojo::Base 'Mojolicious::Plugin::LinkEmbedder::Link::Video';

has media_id => sub {
  my $self = shift;
  my $url  = $self->url;

  $url->query->param('vid') || $url->path->[-1];
};

sub provider_name {'Dagbladet'}

sub learn {
  my ($self, $c, $cb) = @_;

  if ($self->media_id) {
    $self->$cb;
  }
  else {
    $self->SUPER::learn($c, $cb);
  }

  return $self;
}

sub pretty_url {
  my $self     = shift;
  my $media_id = $self->media_id or return $self->SUPER::to_embed;
  my $url      = $self->url->clone;

  $url->fragment(undef);
  $url->query(vid => $media_id);
  $url;
}

sub to_embed {
  my $self = shift;
  my $src  = Mojo::URL->new('http://beta.dbtv.no/player');
  my %args = @_;

  push @{$src->path}, $self->media_id;
  $src->query({autoplay => $args{autoplay} ? 'true' : 'false'});

  $self->_iframe(
    src    => $src,
    class  => 'link-embedder video-dbtv',
    width  => $args{width} || 980,
    height => $args{height} || 551
  );
}

1;
