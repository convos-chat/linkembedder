use Mojo::Base -strict;
use Test::More;
use LinkEmbedder;

plan skip_all => 'TEST_ONLINE=1'         unless $ENV{TEST_ONLINE};
plan skip_all => 'cpanm IO::Socket::SSL' unless LinkEmbedder::TLS;

my @urls = (
  'https://www.facebook.com/watch/?v=2170684279662399',
  'https://www.facebook.com/HachikoDistrict/videos/2170684279662399/',
);

for my $url (@urls) {
  my $encoded_url = Mojo::Util::url_escape($url);

  LinkEmbedder->new->test_ok(
    $url => {
      provider_name => 'Facebook',
      provider_url  => 'https://facebook.com',
      type          => 'rich',
      version       => '1.0',
      cache_age     => 0,
      html =>
        qr{<iframe class="le-rich le-provider-facebook" .* src="https://www\.facebook\.com/plugins/video\.php\?href=$encoded_url},
    }
  );
}

done_testing;
