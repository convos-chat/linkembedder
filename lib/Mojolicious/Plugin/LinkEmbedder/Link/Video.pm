package Mojolicious::Plugin::LinkEmbedder::Link::Video;
use Mojo::Base 'Mojolicious::Plugin::LinkEmbedder::Link';

sub to_embed {
  my $self = shift;
  my $url  = $self->url;
  my $type = $url->path =~ /\.(\w+)$/ ? $1 : 'unknown';
  my %args = @_;
  my @extra;

  $type = $self->_types->type($type) || "unknown/$type";
  $args{height} ||= $self->DEFAULT_VIDEO_HEIGHT;
  $args{width}  ||= $self->DEFAULT_VIDEO_WIDTH;

  local $" = ' ';
  push @extra, 'autoplay' if $args{autoplay};
  unshift @extra, '' if @extra;

  return $self->tag(
    video  => width => $args{width},
    height => $args{height},
    class  => 'link-embedder',
    @extra,
    preload  => 'metadata',
    controls => undef,
    sub {
      return join('',
        $self->tag(source => src   => $url,    type => $type),
        $self->tag(p      => class => 'alert', 'Your browser does not support the video tag.'));
    }
  );
}

1;
