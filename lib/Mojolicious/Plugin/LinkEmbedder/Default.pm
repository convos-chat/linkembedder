package Mojolicious::Plugin::LinkEmbedder::Default;

=head1 NAME

Mojolicious::Plugin::LinkEmbedder::Default - Default class for links

=cut

use Mojo::Base -base;
use Mojo::Loader;
use Mojo::URL;
use Mojo::UserAgent;
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

has _ua => sub {
  Mojo::UserAgent->new(request_timeout => 3);
};

=head1 METHODS

=head2 new

Creates a new object. Required parameter is L</url>, either as an object or
string.

The object returned may be of a subclass, if the the URL is recognized.

=cut

sub new {
  my $class = shift;
  my $url = @_ % 2 == 1 ? shift : '';
  my $self = Mojo::Base::new($class, @_);
  my $type;

  $self->{url} = $self->_massage_url($url || $self->{url});

  if($self->{url}->path =~ /(?:jpg|png|gif)/i) {
    $self->_rebless('Image');
  }
  else {
    $type = $self->{url}->host || 'default';
    $type =~ s/^(?:www|my)\.//;
    $type =~ s/\.\w+$//;
    $type =~ s/\.(\w+)/{ ucfirst $1 }/ge;
    $type =~ s/^(\d+)/_$1/;
    $self->_rebless($type);
  }

  $self;
}

=head2 rebless

  $self->rebless(sub {
    my($self) = @_;
    # ...
  });

This async method will make a deeper check, to see if it's possible to figure
out more information from the URL, such as inspecting content type by doing a
C<HEAD> on L</url>.

=cut

sub rebless {
  my($self, $cb) = @_;

  if(ref $self eq __PACKAGE__) {
    Scalar::Util::weaken($self);
    $self->_ua->head($self->url, sub {
      my $ct = $_[1]->res->headers->content_type || '';
      return $cb->($self->_rebless('Image')) if $ct =~ /^image/;
      return $cb->($self);
    });
  }
  else {
    $cb->($self);
  }
}

=head2 is_movie

Returns true if URL points to a movie.

=cut

sub is_movie {
  shift->url->path =~ m/\.(?:mpg|mpeg|mov)$/i ? 1 : 0;
}

=head2 is_media

Returns true if URL points to media.

=cut

sub is_media {
  shift->url->path =~ m/\.(?:swf|flv|mp3|jpg|png|gif)$/i ? 1 : 0;
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
  my($self, $type) = @_;
  my $class = 'Mojolicious::Plugin::LinkEmbedder::' .ucfirst $type;

  eval "require $class";
  return $self if $@ =~ /^Can't locate/;
  die $@ if $@;
  return bless $self, $class;
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
