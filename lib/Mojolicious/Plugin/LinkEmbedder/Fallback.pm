package Mojolicious::Plugin::LinkEmbedder::Fallback;

=head1 NAME

Mojolicious::Plugin::LinkEmbedder::Fallback - Fallback class for links

=head1 DESCRIPTION

This class inherit from L<Mojolicious::Plugin::LinkEmbedder::Base>.

=cut

use Mojo::Base 'Mojolicious::Plugin::LinkEmbedder::Base';

=head1 METHODS

=head2 to_embed

Returns a link to the L</url>, with target "_blank".

=cut

sub to_embed {
  my $self = shift;
  my $url = $self->url;

  qq(<a href="$url" target="_blank">$url</a>);
}

=head1 AUTHOR

Jan Henning Thorsen - C<jan.henning@thorsen.pm>

=cut

1;
