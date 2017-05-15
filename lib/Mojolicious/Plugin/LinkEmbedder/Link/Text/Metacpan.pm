package Mojolicious::Plugin::LinkEmbedder::Link::Text::Metacpan;
use Mojo::Base 'Mojolicious::Plugin::LinkEmbedder::Link::Text::HTML';

sub provider_name {'Metacpan'}

sub _learn_from_dom {
  my ($self, $dom) = @_;

  if (my $e = $dom->at('.author-pic > a > img') || $dom->at('link[rel="apple-touch-icon"]')) {
    my $url = $e->{src} || $e->{href};
    $self->image($url =~ /^https?:/ ? $url : "//metacpan.org$url");
  }

  $self->SUPER::_learn_from_dom($dom);
}

1;
