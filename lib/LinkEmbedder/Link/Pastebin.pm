package LinkEmbedder::Link::Pastebin;
use Mojo::Base 'LinkEmbedder::Link';

has provider_name => 'Pastebin';
has provider_url  => sub { Mojo::URL->new('https://pastebin.com') };
has _paste        => undef;

sub _learn_from_dom {
  my ($self, $dom) = @_;

  $self->SUPER::_learn_from_dom($dom);

  if (my $e = $dom->at('textarea#paste_code')) {
    $self->_paste($e->text);
  }
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
