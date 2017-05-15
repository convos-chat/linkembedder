package Mojolicious::Plugin::LinkEmbedder::Link::Text::PasteScsysCoUk;
use Mojo::Base 'Mojolicious::Plugin::LinkEmbedder::Link::Text';
use Mojo::Util ();

has media_id => sub {
  shift->url->path =~ m!^/?(\d+)! ? $1 : '';
};

sub provider_name {'scsys.co.uk'}

sub learn {
  my ($self, $c, $cb) = @_;
  my $raw_url = $self->raw_url or return $self->SUPER::learn($c, $cb);

  $self->ua->get(
    $raw_url,
    sub {
      my ($ua, $tx) = @_;
      $self->{text} = Mojo::Util::xml_escape($tx->res->body) if $tx->success;
      $self->$cb;
    },
  );
}

sub raw_url {
  my $self = shift;
  my $media_id = $self->media_id or return;

  Mojo::URL->new("http://paste.scsys.co.uk/$media_id?tx=on");
}

1;
