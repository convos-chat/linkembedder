package Mojolicious::Plugin::LinkEmbedder::Default;

=head1 NAME

Mojolicious::Plugin::LinkEmbedder::Default - Default class for links

=cut

use Mojo::Base -base;
use Mojo::Loader;
use Mojo::URL;
use Mojo::Util 'xml_escape';
use overload (
  q("") => sub { shift->to_embed },
  fallback => 1,
);

=head1 ATTRIBUTES

=head2 url

Holds a L<Mojo::URL> object.

=cut

sub url { shift->{url} }

=head1 METHODS

=head2 new

Creates a new object. Required parameter is L</url>, either as an object or
string.

=cut

sub new {
  my $class = shift;
  my $url = @_ % 2 == 1 ? shift : '';
  my $self = Mojo::Base::new($class, @_);

  $self->{url} = $self->_massage_url($url || $self->{url});
  $self->_rebless($self->{url});
  $self;
}

=head2 is_movie

Returns true if URL points to a movie.

=cut

sub is_movie {
  shift->url =~ m/\.(?:mpg|mpeg|mov)$/i ? 1 : 0;
}

=head2 is_media

Returns true if URL points to media.

=cut

sub is_media {
  shift->url =~ m/\.(?:swf|flv|mp3|jpg|png|gif)$/i ? 1 : 0;
}

=head2 media_id

Returns the part of the URL identifying the media. Default is empty string.

=cut

sub media_id { shift->{media_id} || '' }

=head2 to_embed

The default embed code is just a link to the L</url>, with target "_blank".

=cut

sub to_embed {
  my $self = shift;
  my $url = $self->url;

  qq(<a href="$url" target="_blank">$url</a>);
}

sub _rebless {
  my($self, $url) = @_;
  my $type = $url->host || 'default';
  my($class, $e);

  $type =~ s/^(?:www|my)\.//;
  $type =~ s/\.\w+$//;
  $type =~ s/\.(\w+)/{ ucfirst $1 }/ge;
  $type =~ s/^(\d+)/_$1/;
  $class = 'Mojolicious::Plugin::LinkEmbedder::' .ucfirst $type;
  eval "require $class";
  return $self if $@ =~ /^Can't locate/;
  die $@ if $@;
  bless $self, $class;
}

sub _massage_url {
  my $self = shift;
  my $url = shift or die "'url' is required parameter";

  $url = Mojo::URL->new($url) unless ref $url;
  $url;
}

=head1 AUTHOR

Marcus Ramberg

=cut

1;
