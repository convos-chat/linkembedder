use t::App;
use Test::More;

plan skip_all => 'TEST_ONLINE=1 need to be set' unless $ENV{TEST_ONLINE};

$t->get_ok('/embed?url=https://vimeo.com/86404451')
  ->element_exists('iframe[src="//player.vimeo.com/video/86404451?portrait=0&color=ffffff"]')
  ->element_exists('iframe[width="500"][height="281"][frameborder="0"]');

$t->get_ok('/embed.json?url=https://vimeo.com/86404451')->json_is('/media_id', '86404451')
  ->json_like('/pretty_url', qr{^https?://vimeo\.com/86404451})->json_like('/url', qr{^https?://vimeo\.com/86404451});

done_testing;
