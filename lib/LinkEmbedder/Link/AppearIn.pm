package LinkEmbedder::Link::AppearIn;
use Mojo::Base 'LinkEmbedder::Link';

has provider_name => 'AppearIn';
has provider_url  => sub { Mojo::URL->new('https://appear.in') };
has room          => undef;

sub learn {
  my ($self, $cb) = @_;
  my $path = $self->url->path;

  return $self->SUPER::learn($cb) unless @$path == 1;

  $self->height(390) unless $self->height;
  $self->width(740)  unless $self->width;
  $self->type('rich');
  $self->room($path->[0]);
  $self->title("Join the room $path->[0]");

  $self->$cb if $cb;
  return $self;
}

sub _template {
  my $self = shift;
  return $self->SUPER::_template(@_) unless $self->room;
  return __PACKAGE__, 'rich.html.ep';
}

1;

__DATA__
@@ rich.html.ep
<iframe width="<%= $l->width %>" height="<%= $l->height %>" style="border:0"
  frameborder="0" src="https://appear.in/<%= $l->room %>">
</iframe>
