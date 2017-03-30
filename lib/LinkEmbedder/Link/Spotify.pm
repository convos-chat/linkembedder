package LinkEmbedder::Link::Spotify;
use Mojo::Base 'LinkEmbedder::Link';

has height        => '100';
has provider_name => 'Spotify';
has provider_url  => sub { Mojo::URL->new('https://spotify.com') };
has theme         => 'white';
has view          => 'coverart';
has width         => '300';

has _uri => sub { Mojo::URL->new('https://embed.spotify.com') };

sub learn {
  my ($self, $cb) = @_;
  my $url = $self->url;
  my @path;

  if ($url =~ s!^spotify:!!) {    # spotify:track:5tv77MoS0TzE0sJ7RwTj34
    @path = split /:/, $url;
  }
  elsif (@{$url->path} == 2) {    # http://open.spotify.com/artist/6VKNnZIuu9YEOvLgxR6uhQ
    @path = @{$url->path};
  }

  return $self->SUPER::learn($cb) unless @path;

  $self->_uri->query(theme => $self->theme, uri => join(':', spotify => @path), view => $self->view,);
  $self->type('rich');
  $self->$cb if $cb;
  $self;
}

sub _template {
  my $self = shift;
  return $self->SUPER::_template unless $self->_uri;
  return __PACKAGE__, sprintf 'rich.html.ep';
}

1;

__DATA__
@@ rich.html.ep
<iframe width="<%= $l->width %>" height="<%= $l->height %>" style="border:0"
  frameborder="0" allowtransparency="true" src="<%= $l->_uri %>">
</iframe>
