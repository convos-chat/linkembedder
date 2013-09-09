package Mojolicious::Plugin::LinkEmbedder::Image;

=head1 NAME

Mojolicious::Plugin::LinkEmbedder::Image - Image URL

=cut

use Mojo::Base 'Mojolicious::Plugin::LinkEmbedder::Default';

=head1 METHODS

=head2 is_media

Returns true.

=cut

sub is_media { 1 }

=head2 to_embed

Returns an img tag.

=cut

sub to_embed {
  my $self = shift;
  my $url = $self->url;
  my %args = @_;

  $args{alt} ||= $url->to_string;

  return qq(<img src="$url" alt="$args{alt}">);
}

=head1 AUTHOR

Jan Henning Thorsen - C<jhthorsen@cpan.org>

=cut

1;
