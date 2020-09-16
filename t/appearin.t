use Mojo::Base -strict;
use Test::More;
use LinkEmbedder;

plan skip_all => 'cpanm IO::Socket::SSL' unless LinkEmbedder::TLS;
plan skip_all => 'TEST_ONLINE=1'         unless $ENV{TEST_ONLINE};

LinkEmbedder->new->test_ok(
  'https://whereby.com/your-room-name' => {
    cache_age     => 0,
    height        => 390,
    html          => qr{src="https://whereby\.com/your-room-name"},
    isa           => 'LinkEmbedder::Link::AppearIn',
    provider_name => 'AppearIn',
    provider_url  => 'https://whereby.com',
    title         => 'Join the room your-room-name',
    type          => 'rich',
    url           => 'https://whereby.com/your-room-name',
    version       => '1.0',
    width         => 740,
  }
);

done_testing;
