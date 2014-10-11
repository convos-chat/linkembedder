use t::App;
use Test::More;

$t->get_ok('/embed?url=http://www.ted.com/talks/ryan_holladay_to_hear_this_music_you_have_to_be_there_literally.html')
  ->content_is(
  q(<iframe src="http://embed.ted.com/talks/ryan_holladay_to_hear_this_music_you_have_to_be_there_literally.html" width="560" height="315" frameborder="0" scrolling="no" webkitAllowFullScreen mozallowfullscreen allowFullScreen></iframe>')
  );

$t->get_ok(
  '/embed.json?url=http://www.ted.com/talks/ryan_holladay_to_hear_this_music_you_have_to_be_there_literally.html')
  ->json_is('/media_id', 'ryan_holladay_to_hear_this_music_you_have_to_be_there_literally')
  ->json_is('/pretty_url',
  'http://www.ted.com/talks/ryan_holladay_to_hear_this_music_you_have_to_be_there_literally.html')
  ->json_is('/url', 'http://www.ted.com/talks/ryan_holladay_to_hear_this_music_you_have_to_be_there_literally.html');

done_testing;
