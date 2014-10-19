use t::App;
use Test::More;

$t->get_ok('/embed?url=https://vimeo.com/86404451')
  ->element_exists('iframe[src="//player.vimeo.com/video/86404451?portrait=0&color=ffffff"]')
  ->element_exists('iframe[width="500"][height="281"][frameborder="0"]');

$t->get_ok('/embed.json?url=https://vimeo.com/86404451')->json_is('/media_id', '86404451')
  ->json_is('/pretty_url', 'http://vimeo.com/86404451')->json_is('/url', 'http://vimeo.com/86404451');

done_testing;
