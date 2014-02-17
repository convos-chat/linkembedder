use t::App;
use Test::More;

$t->get_ok('/embed?url=https://twitter.com/jhthorsen/status/434045220116643843')
  ->content_is(q(<iframe src="https://twitframe.com/?url=https://twitter.com/jhthorsen/status/434045220116643843" frameborder="0" height="250" width="550"></iframe>))
  ;

$t->get_ok('/embed?url=https://twitter.com/jhthorsen')
  ->content_is(q(<a href="https://twitter.com/jhthorsen" target="_blank">https://twitter.com/jhthorsen</a>))
  ;

done_testing;
