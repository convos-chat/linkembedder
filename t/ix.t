use Mojo::Base -strict;
use Test::Deep;
use Test::More;
use LinkEmbedder;

plan skip_all => 'TEST_ONLINE=1' unless $ENV{TEST_ONLINE};

my $embedder = LinkEmbedder->new;

my $link = $embedder->get('http://ix.io/fpW');
isa_ok($link, 'LinkEmbedder::Link::Ix');
cmp_deeply(
  $link->TO_JSON,
  {
    cache_age     => 0,
    html          => "<pre>Hello world.\n</pre>\n",
    provider_name => 'Ix',
    provider_url  => 'http://ix.io',
    type          => 'rich',
    url           => 'http://ix.io/fpW',
    version       => '1.0',
  },
  'http://ix.io/fpW',
) or note $link->_dump;

done_testing;
