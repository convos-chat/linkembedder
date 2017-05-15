package Mojolicious::Plugin::LinkEmbedder::Link::Image;
use Mojo::Base 'Mojolicious::Plugin::LinkEmbedder::Link';

sub to_embed {
  my $self = shift;
  my %args = @_;

  $self->tag(img => src => $self->url, alt => $args{alt} || $self->url);
}

1;
