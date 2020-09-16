use Mojo::Base -strict;
use Test::More;
use LinkEmbedder;

plan skip_all => 'TEST_ONLINE=1'         unless $ENV{TEST_ONLINE};
plan skip_all => 'cpanm IO::Socket::SSL' unless LinkEmbedder::TLS;

my $embedder = LinkEmbedder->new;
is $embedder->ua->max_redirects, 3, 'max_redirects';

# cheating to force google to serve complete page
$embedder->ua->transactor->name(
  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.88 Safari/537.36'
);

$embedder->test_ok(
  'https://www.google.no/maps/place/Oslo,+Norway/@59.8937806,10.6450355,11z/data=!3m1!4b1!4m5!3m4!1s0x46416e61f267f039:0x7e92605fd3231e9a!8m2!3d59.9138688!4d10.7522454'
    => {
    isa           => 'LinkEmbedder::Link::Google',
    cache_age     => 0,
    html          => qr{<iframe.*src="https://www\.google\.com/maps\?q=Oslo%2C%2BNorway\+%4059\.8937806%2C10\.6450355"},
    provider_name => 'Google',
    provider_url  => 'https://google.com',
    title         => 'Oslo, Norway',
    type          => 'rich',
    url =>
      'https://www.google.no/maps/place/Oslo,+Norway/@59.8937806,10.6450355,11z/data=!3m1!4b1!4m5!3m4!1s0x46416e61f267f039:0x7e92605fd3231e9a!8m2!3d59.9138688!4d10.7522454',
    version => '1.0',
    }
);

$embedder->test_ok(
  'https://www.google.no/imgres?imgurl=https://c8.alamy.com/comp/P2T31A/godzilla-head-japan-160-0021-tokyo-shinjuku-kabukicho-P2T31A.jpg&imgrefurl=https://www.alamy.com/godzilla-head-japan-160-0021-tokyo-shinjuku-kabukicho-image208282966.html&tbnid=RdZZTG9VLp1cUM&vet=1&docid=eRdXfEMEpJLI_M&w=865&h=1390&q=godzilla+tokyo+shinjuku&hl=en-us&source=sh/x/im'
    => {
    isa              => 'LinkEmbedder::Link::Google',
    cache_age        => 0,
    provider_name    => 'Google',
    provider_url     => 'https://google.com',
    thumbnail_height => 1390,
    thumbnail_url =>
      'https://c8.alamy.com/comp/P2T31A/godzilla-head-japan-160-0021-tokyo-shinjuku-kabukicho-P2T31A.jpg',
    thumbnail_width => 865,
    type            => 'rich',
    version         => '1.0'
    }
);

local $TODO = 'Failing after google changed markup';
$embedder->test_ok(
  'https://images.app.goo.gl/4Ly4KAxTc4CDN9SJ7' => {
    isa => 'LinkEmbedder::Link::Google',
    thumbnail_url =>
      'https://c8.alamy.com/comp/P2T31A/godzilla-head-japan-160-0021-tokyo-shinjuku-kabukicho-P2T31A.jpg',
  }
);

done_testing;
