package LinkEmbedder::Link::oEmbed;
use Mojo::Base 'LinkEmbedder::Link';

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
    $self->ua->get($api_url => sub { $self->tap(_learn_from_json => $_[1])->$cb });
  }
  else {
    $self->_learn_from_json($self->ua->get($api_url));
  }

  return $self;
}

1;
