package LinkEmbedder::Link::Github;
use Mojo::Base 'LinkEmbedder::Link';

has provider_name => 'GitHub';
has provider_url => sub { Mojo::URL->new('https://github.com') };

sub _learn_from_dom {
  my ($self, $dom) = @_;
  my $e;

  $self->SUPER::_learn_from_dom($dom);

  # Clean up title
  if ($e = $dom->at('title')) {
    $e = $e->all_text;
    $e =~ s!^\s*GitHub\W+!!si;
    $e =~ s![^\w\)\]\}]+GitHub\s*$!!si;
    $self->title($e);
  }

  # Pages with a readme file
  my $skip = $self->title;
  $skip =~ s!\S+:\s+(\w)!$1!;    # remove "username/repo:"
  for my $e ($dom->find('#readme p')->each) {
    my $text = $e->all_text || '';
    next unless $text =~ /\w/;
    next unless index($text, $skip) == -1;
    $self->description($text);
    last;
  }
}

1;
