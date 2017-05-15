package Mojolicious::Plugin::LinkEmbedder::Link::Image::Xkcd;
use Mojo::Base 'Mojolicious::Plugin::LinkEmbedder::Link::Image';

has media_id => sub { shift->url->path->[0] };
sub provider_name {'Xkcd'}
has [qw( media_hover_text media_url media_title )];

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
      my $link = $tx->res->dom->at('#comic img') || {};
      $self->media_url(Mojo::URL->new($link->{src})) if $link->{src};
      $self->media_title($link->{alt} || $link->{title} || $self->url);
      $self->media_hover_text($link->{title} || $self->media_title);
      $self->$cb;
    },
  );
  $delay->wait unless $delay->ioloop->is_running;
}

sub to_embed {
  my $self = shift;

  $self->tag(img => src => $self->media_url, alt => $self->media_title, title => $self->media_hover_text);
}

1;
