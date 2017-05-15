package Mojolicious::Plugin::LinkEmbedder::Link::Image::Instagram;
use Mojo::Base 'Mojolicious::Plugin::LinkEmbedder::Link::Image';

sub learn {
  my ($self, $c, $cb) = @_;
  my $ua  = $self->{ua};
  my $url = Mojo::URL->new('https://api.instagram.com/oembed');

  $url->query(url => $self->url);

  my $delay = Mojo::IOLoop->delay(
    sub {
      my $delay = shift;
      $ua->get($url, $delay->begin);
    },
    sub {
      my ($ua, $tx) = @_;
      my $json = $tx->res->json;

      $self->author_name($json->{author_name});
      $self->author_url($json->{author_url});
      $self->media_id($json->{media_id});
      $self->provider_url($json->{provider_url});
      $self->provider_name($json->{provider_name});
      $self->title($json->{title});
      $self->{html} = $json->{html};
      $self->$cb;
    },
  );
  $delay->wait unless $delay->ioloop->is_running;
}

sub to_embed { shift->{html} || '' }

1;
