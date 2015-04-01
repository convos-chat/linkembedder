package Mojolicious::Plugin::LinkEmbedder::Link::Text;

=head1 NAME

Mojolicious::Plugin::LinkEmbedder::Link::Text - Text URL

=head1 DESCRIPTION

This class inherit from L<Mojolicious::Plugin::LinkEmbedder::Link>.

=cut

use Mojo::Base 'Mojolicious::Plugin::LinkEmbedder::Link';
use Mojo::Util ();

=head2 to_embed

Returns the HTML code for a script tag that writes the gist.

=cut

sub to_embed {
  my $self = shift;

  return $self->SUPER::to_embed unless $self->{text};
  return $self->tag(pre => class => 'link-embedder text-paste', sub { Mojo::Util::xml_escape($self->{text}) });
}

=head1 AUTHOR

Jan Henning Thorsen - C<jhthorsen@cpan.org>

=cut

1;
