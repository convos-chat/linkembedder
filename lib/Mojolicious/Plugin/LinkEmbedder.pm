package Mojolicious::Plugin::LinkEmbedder;

=head1 NAME

Mojolicious::Plugin::LinkEmbedder - Convert a URL to embedded content

=head1 VERSION

0.01

=head1 DESCRIPTION

This module can transform a URL to an iframe, image or other embeddable
content.

=head1 SYNOPSIS

  use Mojolicious::Lite;
  plugin 'LinkEmbedder';

  get '/embed' => sub {
    my $self = shift;
    my $link = $self->embed_link($self->param('url'));

    $self->respond_to(
      json => {
        json => {
          is_media => $link->is_media,
          is_movie => $link->is_movie,
          media_id => $link->media_id,
          url => $link->url->to_string,
        },
      },
      any => { text => "$link" },
    );
  };

  get '/rebless' => sub {
    my $self = shift->render_later;
    my $link = $self->embed_link($self->param('url'));

    $link->rebless(sub {
      $self->render(text => $link->to_embed);
    });
  };

  app->start;

=head1 SUPPORTED LINKS

=over 4

=item * L<Mojolicious::Plugin::LinkEmbedder::Default>

=item * L<Mojolicious::Plugin::LinkEmbedder::Image>

=item * L<Mojolicious::Plugin::LinkEmbedder::Youtube>

=back

=cut

use Mojo::Base 'Mojolicious::Plugin';
use Mojolicious::Plugin::LinkEmbedder::Default;

our $VERSION = '0.01';

=head1 METHODS

=head2 register

Will register the L</embed_link> helper which creates new objects from
L<Mojolicious::Plugin::LinkEmbedder::Default>.

=cut

sub register {
  my($self, $app, $config) = @_;

  $app->helper(embed_link => sub {
    Mojolicious::Plugin::LinkEmbedder::Default->new($_[1]);
  });
}

=head1 AUTHOR

Jan Henning Thorsen - C<jhthorsen@cpan.org>

Marcus Ramberg - C<mramberg@cpan.org>

=cut

1;
