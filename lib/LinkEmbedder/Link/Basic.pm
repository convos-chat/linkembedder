package LinkEmbedder::Link::Basic;
use Mojo::Base 'LinkEmbedder::Link';

my $PHOTO_RE = qr!\.(?:jpg|png|gif)\b!i;
my $VIDEO_RE = qr!\.(?:mpg|mpeg|mov|mp4|ogv)\b!i;

sub learn {
  my ($self, $cb) = @_;
  my $url = $self->url;
  my $type = $url =~ $PHOTO_RE ? 'photo' : $url =~ $VIDEO_RE ? 'video' : 'link';

  $self->type($type);

  # Need to learn more from an http request
  if ($type eq 'link') {
    $self->SUPER::learn($cb);
  }
  else {
    $self->_learn_from_url;
    $self->$cb if $cb;
  }

  return $self;
}

1;
