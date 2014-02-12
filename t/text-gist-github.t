use t::App;
use Test::More;

$t->get_ok('/embed?url=https://gist.github.com/jhthorsen/6449446')
  ->content_is(q(<script src="https://gist.github.com/jhthorsen/6449446.js"></script>))
  ;

done_testing;
