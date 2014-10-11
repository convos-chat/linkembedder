package Mojolicious::Plugin::LinkEmbedder::Link::Video::Ted;

=head1 NAME

Mojolicious::Plugin::LinkEmbedder::Link::Video::Ted - ted.com video

=head1 DESCRIPTION

This class inherit from L<Mojolicious::Plugin::LinkEmbedder::Link::Video>.

=cut

use Mojo::Base 'Mojolicious::Plugin::LinkEmbedder::Link::Video';

=head1 ATTRIBUTES

=head2 media_id

Returns the the digit from the url L</url>.

=cut

has media_id => sub {
  my $self     = shift;
  my $media_id = $self->url->path->[-1];

  $media_id =~ s!\.html$!!;
  $media_id;
};

=head1 METHODS

=head2 to_embed

Returns the HTML code for an iframe embedding this movie.

=cut

sub to_embed {
  my $self     = shift;
  my $media_id = $self->media_id or return $self->SUPER::to_embed;
  my %args     = @_;

  $args{height} ||= 315;
  $args{width}  ||= 560;

  qq(<iframe src="http://embed.ted.com/talks/$media_id.html" width="$args{width}" height="$args{height}" frameborder="0" scrolling="no" webkitAllowFullScreen mozallowfullscreen allowFullScreen></iframe>');
}

=head1 AUTHOR

Marcus Ramberg

=cut

1;
