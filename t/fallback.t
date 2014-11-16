use t::App;
use Test::More;

plan skip_all => 'TEST_ONLINE=1 need to be set' unless $ENV{TEST_ONLINE};

my $url_re = qr{^https?.*google\.};

$t->get_ok('/embed?url=http://google.com')->text_like('a[href*="google"]', $url_re);

$t->get_ok('/embed.json?url=http://google.com')->json_like('/pretty_url', $url_re)->json_like('/url', $url_re);

local $TODO = 'Not sure what media_id should hlld';
$t->json_is('/media_id', '');

done_testing;
