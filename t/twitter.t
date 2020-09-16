use Mojo::Base -strict;
use Test::More;
use LinkEmbedder;

plan skip_all => 'TEST_ONLINE=1'         unless $ENV{TEST_ONLINE};
plan skip_all => 'cpanm IO::Socket::SSL' unless LinkEmbedder::TLS;

local $TODO = 'https://github.com/jhthorsen/linkembedder/issues/14';

my %expected = (
  cache_age     => '3153600000',
  provider_name => 'Twitter',
  provider_url  => 'https://twitter.com',
  type          => 'rich',
  version       => '1.0',
);

LinkEmbedder->new->test_ok(
  'https://twitter.com/jhthorsen' => {
    %expected,
    cache_age     => 0,
    author_name   => qr{Jan Henning Thorsen},
    author_url    => 'https://twitter.com/jhthorsen',
    html          => qr{<h3>Jan Henning Thorsen},
    thumbnail_url => qr{twimg\.com/profile_images/.*_400x400},
    title         => qr{Jan Henning Thorsen},
    url           => 'https://twitter.com/jhthorsen',
  }
);

LinkEmbedder->new->test_ok(
  'https://twitter.com/jhthorsen/status/434045220116643843' => {
    %expected,
    author_name   => 'Jan Henning Thorsen',
    author_url    => 'https://twitter.com/jhthorsen',
    html          => qr{blockquote.*href="https://twitter.com/jhthorsen/status/434045220116643843"}s,
    thumbnail_url => qr{twimg\.com/profile_images/.*_400x400},
    title         => 'Jan Henning Thorsen on Twitter',
    url           => 'https://twitter.com/jhthorsen/status/434045220116643843',
  }
);

LinkEmbedder->new->test_ok(
  'https://twitter.com/mulligan/status/555050159189413888/' => {
    author_name   => 'Brenden Mulligan',
    author_url    => 'https://twitter.com/mulligan',
    html          => qr{blockquote.*href="https://twitter.com/mulligan/status/555050159189413888"}s,
    thumbnail_url => 'https://pbs.twimg.com/media/B7PvLOSCMAEmBKU.jpg:large',
    title         => 'Brenden Mulligan on Twitter',
    url           => 'https://twitter.com/mulligan/status/555050159189413888',
  }
);

LinkEmbedder->new->test_ok(
  'https://twitter.com/mulligan/status/555050159189413888/photo/1' => {
    %expected,
    author_name   => 'Brenden Mulligan',
    author_url    => 'https://twitter.com/mulligan',
    html          => qr{blockquote.*href="https://twitter.com/mulligan/status/555050159189413888/photo/1"}s,
    thumbnail_url => 'https://pbs.twimg.com/media/B7PvLOSCMAEmBKU.jpg:large',
    title         => 'Brenden Mulligan on Twitter',
    url           => 'https://twitter.com/mulligan/status/555050159189413888/photo/1',
  }
);

done_testing;
