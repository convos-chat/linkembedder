use t::App;
use Test::More;

$t->get_ok('/embed?url=https://vimeo.com/86404451')
  ->content_is(
  q(<iframe src="//player.vimeo.com/video/86404451?portrait=0&amp;color=ffffff" width="500" height="281" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>)
  );

$t->get_ok('/embed.json?url=https://vimeo.com/86404451')->json_is('/media_id', '86404451')
  ->json_is('/pretty_url', 'https://vimeo.com/86404451')->json_is('/url', 'https://vimeo.com/86404451');

done_testing;
