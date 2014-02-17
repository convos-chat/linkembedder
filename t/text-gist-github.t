use t::App;
use Test::More;

$t->get_ok('/embed?url=https://gist.github.com/jhthorsen/6449446')
  ->content_is(q(<script src="https://gist.github.com/jhthorsen/6449446.js"></script>))
  ;

$t->get_ok('/embed?url=https://gist.github.com/jhthorsen')
  ->content_is(q(<a href="https://gist.github.com/jhthorsen" target="_blank">https://gist.github.com/jhthorsen</a>))
  ;

done_testing;
