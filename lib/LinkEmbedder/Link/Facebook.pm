package LinkEmbedder::Link::Facebook;
use Mojo::Base 'LinkEmbedder::Link';

use Mojo::Util;

has provider_name => 'Facebook';
has provider_url  => sub { Mojo::URL->new('https://facebook.com') };

sub learn_p {
  my $self = shift;
  my $path = $self->url->path;
  return $self->_learn_from_video_p if $path->[0] and $path->[0] eq 'watch';
  return $self->_learn_from_video_p if $path->[1] and $path->[1] eq 'videos';
  return $self->SUPER::learn_p(@_);
}

sub _learn_from_video_p {
  my $self = shift;
  $self->template([__PACKAGE__, 'iframe.html.ep']);
  $self->type('rich');
  return Mojo::Promise->resolve($self);
}

1;

__DATA__
@@ iframe.html.ep
<iframe class="le-rich le-provider-facebook" width="476" height="476" style="border:0;width:100%" frameborder="0" allowfullscreen src="https://www.facebook.com/plugins/video.php?href=<%== Mojo::Util::url_escape($l->url) %>&show_text=0&width=476"></iframe>
