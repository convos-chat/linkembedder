use t::App;
use Test::More;

$t->get_ok('/embed?url=http://www.youtube.com/watch?v=4BMYH-AQyy0')
  ->content_is(q(<iframe width="640" height="390" src="http://www.youtube.com/embed/4BMYH-AQyy0">))
  ;

$t->get_ok('/embed.json?url=http://www.youtube.com/watch?v=4BMYH-AQyy0')
  ->json_is('/is_media', 0)
  ->json_is('/is_movie', 1)
  ->json_is('/media_id', '4BMYH-AQyy0')
  ;

done_testing;
