package Mojolicious::Plugin::LinkEmbedder::Link;

=head1 NAME

Mojolicious::Plugin::LinkEmbedder::Link - Base class for links

=cut

use Mojo::Base -base;
use Mojo::ByteStream;
use Mojo::Util;
use Mojolicious::Types;

# this may change in future version
use constant DEFAULT_VIDEO_HEIGHT => 390;
use constant DEFAULT_VIDEO_WIDTH  => 640;

=head1 ATTRIBUTES

=head2 media_id

Returns the part of the URL identifying the media. Default is empty string.

=head2 ua

Holds a L<Mojo::UserAgent> object.

=head2 url

Holds a L<Mojo::URL> object.

=cut

has media_id => '';
has ua => sub { die "Required in constructor" };

sub url { shift->{url} }

# should this be public?
has _tx => undef;

has _types => sub {
  my $types = Mojolicious::Types->new;
  $types->type(mpg  => 'video/mpeg');
  $types->type(mpeg => 'video/mpeg');
  $types->type(mov  => 'video/quicktime');
  $types;
};

=head1 METHODS

=head2 is

  $bool = $self->is($str);
  $bool = $self->is('video');
  $bool = $self->is('video-youtube');

Convertes C<$str> using L<Mojo::Util/camelize> and checks if C<$self>
is of that type:

  $self->isa('Mojolicious::Plugin::LinkEmbedder::Link::' .Mojo::Util::camelize($_[1]));

=cut

sub is {
  $_[0]->isa(__PACKAGE__ . '::' . Mojo::Util::camelize($_[1]));
}

=head2 learn

  $self->learn($c, $cb);

This method can be used to learn more information about the link. This class
has no idea what to learn, so it simply calls the callback (C<$cb>) with
C<@cb_args>.

=cut

sub learn {
  my ($self, $c, $cb) = @_;
  $self->$cb;
  $self;
}

=head2 pretty_url

Returns a pretty version of the L</url>. The default is to return a cloned
version of L</url>.

=cut

sub pretty_url { shift->url->clone }

=head2 to_embed

Returns a link to the L</url>, with target "_blank".

=cut

sub to_embed {
  my $self = shift;
  my $url  = $self->url;
  my @args;

  push @args, qq(target="_blank");
  push @args, qq(title="Content-Type: @{[$self->_tx->res->headers->content_type]}") if $self->_tx;

  local $" = ' ';
  qq(<a href="$url" @args>$url</a>);
}

sub TO_JSON {
  my $self = shift;

  return {class => ref($self), url => $self->url->to_string, map { ($_ => $self->$_) } $self->_cache_attributes,};
}

sub _cache_attributes { qw( media_id pretty_url ); }

=head1 AUTHOR

Jan Henning Thorsen - C<jan.henning@thorsen.pm>

=cut

1;
