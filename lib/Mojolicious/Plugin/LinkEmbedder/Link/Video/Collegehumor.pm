package Mojolicious::Plugin::LinkEmbedder::Link::Video::Collegehumor;
use Mojo::Base 'Mojolicious::Plugin::LinkEmbedder::Link::Text::HTML';

has media_id => sub { shift->url->path =~ m!/(\d+)/! ? $1 : '' };
sub provider_name {'Collegehumor'}

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

sub to_embed {
  my $self     = shift;
  my $media_id = $self->media_id or return $self->SUPER::to_embed;
  my $src      = Mojo::URL->new('http://www.collegehumor.com/e');
  my %args     = @_;

  push @{$src->path}, $media_id;

  $self->_iframe(
    src    => $src,
    class  => 'link-embedder video-collegehumor',
    width  => $args{width} || 600,
    height => $args{height} || 369
  );
}

1;
