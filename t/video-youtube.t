use t::App;
use Test::More;

$t->get_ok('/embed?url=http://www.youtube.com/watch?v=4BMYH-AQyy0')
  ->content_is(q(<iframe width="640" height="390" src="http://www.youtube.com/embed/4BMYH-AQyy0">));

$t->get_ok('/embed.json?url=http://www.youtube.com/watch?v=4BMYH-AQyy0%26eurl=huh%26mode=huh%26search=huh')
  ->json_is('/media_id', '4BMYH-AQyy0')->json_is('/pretty_url', 'http://www.youtube.com/watch?v=4BMYH-AQyy0')
  ->json_is('/url', 'http://www.youtube.com/watch?v=4BMYH-AQyy0&eurl=huh&mode=huh&search=huh');

done_testing;
