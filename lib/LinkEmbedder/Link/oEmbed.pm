package LinkEmbedder::Link::oEmbed;
use Mojo::Base 'LinkEmbedder::Link';

use constant DEBUG => $ENV{LINK_EMBEDDER_DEBUG} || 0;

# please report back if you add more urls to this hash
our %API = ('instagram.com' => 'https://api.instagram.com/oembed?url=%s');

has html => sub { shift->html };

sub learn {
  my ($self, $cb) = @_;
  my $url  = $self->url;
  my $host = $url->host;

  $host = $1 if $host =~ m!([^\.]+\.\w+)$!;
  my $api_url = $self->{api_url} || $API{$host};

  if (!$api_url) {
    $self->error({message => "Unknown oEmbed provider for $host", code => 400});
    $self->$cb if $cb;
    return $self;
  }

  $api_url = sprintf $api_url, Mojo::Util::url_escape($url);

  if ($cb) {
    $self->ua->get($api_url => sub { $self->tap(_learn => $_[1])->$cb });
  }
  else {
    $self->_learn($self->ua->get($api_url));
  }

  return $self;
}

sub _learn {
  my ($self, $tx) = @_;
  my $json = $tx->res->json;

  warn "[LinkEmbedder] " . $tx->res->text . "\n" if DEBUG;
  $self->{$_} ||= $json->{$_} for keys %$json;
}

1;
