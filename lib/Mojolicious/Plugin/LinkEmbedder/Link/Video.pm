package Mojolicious::Plugin::LinkEmbedder::Link::Video;

=head1 NAME

Mojolicious::Plugin::LinkEmbedder::Link::Video - Video URL

=head1 DESCRIPTION

This class inherit from L<Mojolicious::Plugin::LinkEmbedder::Link>.

=cut

use Mojo::Base 'Mojolicious::Plugin::LinkEmbedder::Link';

=head1 METHODS

=head2 to_embed

TODO. (It returns a video tag for now)

=cut

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
  push @extra, 'controls' if $args{controls};
  unshift @extra, '' if @extra;

  qq(<video width="$args{width}" height="$args{height}"@extra>)
    . qq(<source src="$url" type="$type">)
    . qq(<p class="alert">Your browser does not support the video tag.</p>)
    . qq(</video>);
}

=head1 AUTHOR

Jan Henning Thorsen - C<jhthorsen@cpan.org>

=cut

1;
