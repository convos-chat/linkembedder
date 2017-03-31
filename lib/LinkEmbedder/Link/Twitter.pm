package LinkEmbedder::Link::Twitter;
use Mojo::Base 'LinkEmbedder::Link';

use Mojo::Util 'trim';

has lang         => 'en';
has provider_url => sub { Mojo::URL->new('https://twitter.com') };
has _tweet       => undef;

sub _learn_from_dom {
  my ($self, $dom) = @_;

  $self->SUPER::_learn_from_dom($dom);
  $self->_tweet($self->_wash($dom->at('.permalink-tweet p')));

  my $name = $self->title || '';
  if ($name =~ s! on twitter$!!i) {
    $self->url->path->trailing_slash(0);
    my $url = $self->url->clone;
    @{$url->path} = ($url->path->[0]);
    $self->author_name($name);
    $self->author_url($url);
    $self->cache_age(3153600000);
    $self->template([__PACKAGE__, 'rich.html.ep']);
  }

  my $e;
  if (!$self->thumbnail_url and $e = $dom->at('.ProfileAvatar-image[src]')) {
    $self->author_name(trim($e->{alt} || ''));
    $self->author_url($self->url);
    $self->thumbnail_url($e->{src});
  }
}

1;

__DATA__
@@ rich.html.ep
<div class="card le-card le-<%= $l->type %>">
  <blockquote class="twitter-tweet">
  % if ($l->_tweet) {
    %== $l->_tweet
  % } else {
    <p lang="<%= $l->lang %>" dir="ltr"><%= $l->description %></p>
    &mdash;
    <%= $l->author_name %> // <a href="<%= $l->url %>">@<%= $l->url->path->[0] %></a>
  % }
  </blockquote>
</div>
@@ helper.html.ep
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>
