package LinkEmbedder::Link;
use Mojo::Base -base;

use Mojo::Template;
use Mojo::Util 'trim';

use constant DEBUG => $ENV{LINK_EMBEDDER_DEBUG} || 0;

my %DOM_SEL = (
  ':desc'      => ['meta[property="og:description"]', 'meta[name="twitter:description"]', 'meta[name="description"]'],
  ':image'     => ['meta[property="og:image"]',       'meta[property="og:image:url"]',    'meta[name="twitter:image"]'],
  ':site_name' => ['meta[property="og:site_name"]',   'meta[property="twitter:site"]'],
  ':title'     => ['meta[property="og:title"]',       'meta[name="twitter:title"]',       'title'],
);

my @JSON_ATTRS = (
  'author_name',      'author_url',    'cache_age',       'height', 'provider_name', 'provider_url',
  'thumbnail_height', 'thumbnail_url', 'thumbnail_width', 'title',  'type',          'url',
  'version',          'width'
);

has author_name => undef;
has author_url  => undef;
has cache_age   => 0;
has description => '';
has error       => undef;                                                # {message => "", code => ""}
has height      => sub { $_[0]->type =~ /^photo|video$/ ? 0 : undef };

has provider_name => sub {
  return undef unless my $name = shift->url->host;
  return $name =~ /([^\.]+)\.(\w+)$/ ? ucfirst $1 : $name;
};

has provider_url => sub { $_[0]->url->host ? $_[0]->url->clone->path('/') : undef };
has template => sub { [__PACKAGE__, sprintf '%s.html.ep', $_[0]->type] };
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
  my $template = Mojo::Loader::data_section(@{$self->template}) or return '';
  Mojo::Template->new({auto_escape => 1, prepend => 'my $l=shift'})->render($template, $self);
}

sub learn {
  my ($self, $cb) = @_;
  my $url = $self->url;

  if ($cb) {
    $self->ua->get($url => sub { $self->tap(_learn => $_[1])->$cb });
  }
  else {
    $self->_learn($self->ua->get($url));
  }

  return $self;
}

sub TO_JSON {
  my $self = shift;
  my %json;

  for my $attr (grep { defined $self->$_ } @JSON_ATTRS) {
    $json{$attr} = $self->$attr;
    $json{$attr} = "$json{$attr}" if $attr =~ /url$/;
  }

  $json{html} = $self->html unless $self->type eq 'link';

  return \%json;
}

sub _dump { Mojo::Util::dumper($_[0]->TO_JSON); }

sub _el {
  my ($self, $dom, @sel) = @_;
  @sel = @{$DOM_SEL{$sel[0]}} if $DOM_SEL{$sel[0]};

  for (@sel) {
    my $e = $dom->at($_) or next;
    my $val = trim($e->{content} || $e->{value} || $e->{href} || $e->text || '') or next;
    return $val;
  }
}

sub _learn {
  my ($self, $tx) = @_;
  my $ct = $tx->res->headers->content_type || '';

  $self->type('photo')->_learn_from_url               if $ct =~ m!^image/!;
  $self->type('video')->_learn_from_url               if $ct =~ m!^video/!;
  $self->type('rich')->_learn_from_url                if $ct =~ m!^text/plain!;
  $self->type('rich')->_learn_from_dom($tx->res->dom) if $ct =~ m!^text/html!;

  return $self;
}

sub _learn_from_dom {
  my ($self, $dom) = @_;
  my $v;

  $self->author_name($v)      if $v = $self->_el($dom, '[itemprop="author"] [itemprop="name"]');
  $self->author_url($v)       if $v = $self->_el($dom, '[itemprop="author"] [itemprop="email"]');
  $self->description($v)      if $v = $self->_el($dom, ':desc');
  $self->provider_name($v)    if $v = $self->_el($dom, ':site_name');
  $self->thumbnail_height($v) if $v = $self->_el($dom, 'meta[property="og:image:height"]');
  $self->thumbnail_url($v)    if $v = $self->_el($dom, ':image');
  $self->thumbnail_width($v)  if $v = $self->_el($dom, 'meta[property="og:image:width"]');
  $self->title($v)            if $v = $self->_el($dom, ':title');
}

sub _learn_from_json {
  my ($self, $tx) = @_;
  my $json = $tx->res->json;

  warn "[LinkEmbedder] " . $tx->res->text . "\n" if DEBUG;
  $self->{$_} ||= $json->{$_} for keys %$json;
}

sub _learn_from_url {
  my $self = shift;
  my $path = $self->url->path;

  $self->title(@$path ? $path->[-1] : 'Image');
  $self;
}

sub _wash {
  $_[1] or return $_[0];
  $_[1]->find($_)->map('remove') for qw(embed script);
}

1;

=encoding utf8

=head1 NAME

LinkEmbedder::Link - Meta information for an URL

=head1 SYNOPSIS

See L<LinkEmbedder>.

=head1 DESCRIPTION

L<LinkEmbedder::Link> is a class representing an expanded URL.

=head1 ATTRIBUTES

=head2 author_name

=head2 author_url

=head2 cache_age

=head2 description

=head2 error

=head2 height

=head2 provider_name

=head2 provider_url

=head2 template

=head2 thumbnail_height

=head2 thumbnail_url

=head2 thumbnail_width

=head2 title

=head2 type

=head2 ua

=head2 url

=head2 version

=head2 width

=head1 METHODS

=head2 html

=head2 learn

=head1 AUTHOR

Jan Henning Thorsen

=head1 SEE ALSO

L<LinkEmbedder>

=cut

__DATA__
@@ iframe.html.ep
<iframe width="600" height="400" style="border:0;width:100%" frameborder="0" allowfullscreen src="<%= $l->{iframe_src} %>"></iframe>
@@ link.html.ep
<a href="<%= $l->url %>"><%= Mojo::Util::url_unescape($l->url) %></a>
@@ paste.html.ep
<pre><%= $l->{paste} || '' %></pre>
@@ photo.html.ep
<img src="<%= $l->url %>" alt="<%= $l->title %>">
@@ rich.html.ep
% if ($l->title) {
<div class="card le-card le-<%= $l->type %>">
  <h3><%= $l->title %></h3>
  <p><%= $l->description %></p>
</div>
% } else {
<a href="<%= $l->url %>"><%= Mojo::Util::url_unescape($l->url) %></a>
% }
@@ video.html.ep
<video height="640" width="480" preload="metadata" controls>
% for my $s (@{$l->{sources} || []}) {
  <source src="<%= $s->{url} %>" type="<%= $s->{type} || '' %>">
% }
  <p>Your browser does not support the video tag.</p>
</video>
