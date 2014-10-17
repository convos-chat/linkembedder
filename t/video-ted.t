use t::App;
use Test::More;

$t->get_ok('/embed?url=http://www.ted.com/talks/ryan_holladay_to_hear_this_music_you_have_to_be_there_literally.html')
  ->element_exists(
  'iframe[src="//embed.ted.com/talks/ryan_holladay_to_hear_this_music_you_have_to_be_there_literally.html"]')
  ->element_exists('iframe[width="560"][height="315"]')->element_exists('iframe[frameborder="0"][scrolling="no"]')
  ->content_like(qr{\ballowFullScreen\b});

$t->get_ok(
  '/embed.json?url=http://www.ted.com/talks/ryan_holladay_to_hear_this_music_you_have_to_be_there_literally.html')
  ->json_is('/media_id', 'ryan_holladay_to_hear_this_music_you_have_to_be_there_literally')
  ->json_is('/pretty_url',
  'http://www.ted.com/talks/ryan_holladay_to_hear_this_music_you_have_to_be_there_literally.html')
  ->json_is('/url', 'http://www.ted.com/talks/ryan_holladay_to_hear_this_music_you_have_to_be_there_literally.html');

done_testing;
