package LinkEmbedder::Link::Ix;
use Mojo::Base 'LinkEmbedder::Link';

has provider_name => 'Ix';
has provider_url  => sub { Mojo::URL->new('http://ix.io') };
has _paste        => undef;

sub _learn {
  my ($self, $tx) = @_;

  if ($self->url->path =~ m!^/\w+$!) {
    $self->type('rich');
    $self->_paste($tx->res->text);
  }

  return $self;
}

sub _template {
  my $self = shift;
  return $self->SUPER::_template(@_) unless $self->_paste;
  return __PACKAGE__, 'rich.html.ep';
}

1;

__DATA__
@@ rich.html.ep
<pre><%= $l->_paste %></pre>
