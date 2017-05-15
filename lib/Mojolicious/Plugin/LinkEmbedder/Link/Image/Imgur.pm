package Mojolicious::Plugin::LinkEmbedder::Link::Image::Imgur;
use Mojo::Base 'Mojolicious::Plugin::LinkEmbedder::Link::Image';

has media_id => sub { shift->url->path->[0] };
sub provider_name {'Imgur'}
has [qw( media_url media_title )];

sub learn {
  my ($self, $c, $cb) = @_;
  my $ua    = $self->{ua};
  my $delay = Mojo::IOLoop->delay(
    sub {
      my $delay = shift;
      $ua->get($self->url, $delay->begin);
    },
    sub {
      my ($ua, $tx) = @_;
      my $dom = $tx->res->dom;
      $self->media_url(Mojo::URL->new(($dom->at('meta[property="og:image"]') || {})->{content}));
      $self->media_title(($dom->at('meta[property="og:title"]') || {})->{content});
      $self->$cb;
    },
  );
  $delay->wait unless $delay->ioloop->is_running;
}

sub to_embed {
  my $self = shift;

  $self->tag(
    img => src => $self->media_url,
    alt => $self->media_title || $self->media_url,
    title => $self->media_title
  );
}

1;
