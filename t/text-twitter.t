use t::App;
use Test::More;

$t->get_ok('/embed?url=https://twitter.com/jhthorsen/status/434045220116643843')
  ->content_is(q(<iframe frameborder="0" height="250" width="550" src="//twitframe.com/?url=https://twitter.com/jhthorsen/status/434045220116643843"></iframe>))
  ;

done_testing;
