package Mojolicious::Plugin::LinkEmbedder::Link::Video::Ted;
use Mojo::Base 'Mojolicious::Plugin::LinkEmbedder::Link::Text::HTML';

has media_id => sub {
  my $self     = shift;
  my $media_id = $self->url->path->[-1];

  $media_id =~ s!\.html$!!;
  $media_id;
};

sub provider_name {'Ted'}

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
  my %args     = @_;

  $self->_iframe(
    src    => "//embed.ted.com/talks/$media_id.html",
    class  => 'link-embedder video-ted',
    width  => $args{width} || 560,
    height => $args{height} || 315
  );
}

1;
