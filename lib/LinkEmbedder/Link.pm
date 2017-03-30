package LinkEmbedder::Link;
use Mojo::Base -base;

use Mojo::Util;
use Mojo::Template;

my @JSON_ATTRS = (
  'author_name',      'author_url',    'cache_age',       'height', 'provider_name', 'provider_url',
  'thumbnail_height', 'thumbnail_url', 'thumbnail_width', 'title',  'type',          'url',
  'version',          'width'
);

has author_name => undef;
has author_url  => undef;
has cache_age   => 0;
has error       => undef;                                                # {message => "", code => ""}
has height      => sub { $_[0]->type =~ /^photo|video$/ ? 0 : undef };
has provider_name => sub { shift->_provider_name };
has provider_url => sub { $_[0]->url->host ? $_[0]->url->clone->path('/') : undef };
has thumbnail_height => undef;
has thumbnail_url    => undef;
has thumbnail_width  => undef;
has title            => undef;
has type             => 'link';
has ua               => undef;                                                # Mojo::UserAgent object
has url              => undef;                                                # Mojo::URL
has version          => '1.0';
has width            => sub { $_[0]->type =~ /^photo|video$/ ? 0 : undef };

sub html {
  my $self = shift;
  my $template = Mojo::Loader::data_section(ref($self), sprintf '%s.html.ep', $self->type) or return '';
  Mojo::Template->new({auto_escape => 1, prepend => 'my $l=shift'})->render($template, $self);
}

sub learn {
  my ($self, $cb) = @_;
  Mojo::IOLoop->next_tick(sub { $self->$cb }) if $cb;
  return $self;
}

sub TO_JSON {
  my $self = shift;
  my %json;

  $json{$_} = $self->$_ for grep { defined $self->$_ } @JSON_ATTRS;
  $json{html} = $self->html unless $self->type eq 'link';

  return \%json;
}

sub _provider_name {
  return undef unless my $name = shift->url->host;
  return $name =~ /([^\.]+)\.(\w+)$/ ? ucfirst $1 : $name;
}

1;
__DATA__
@@ link.html.ep
<a href="<%= $l->url %>"><%= Mojo::Util::url_unescape($l->url) %></a>
@@ rich.html.ep
<a href="<%= $l->url %>"><%= Mojo::Util::url_unescape($l->url) %></a>
