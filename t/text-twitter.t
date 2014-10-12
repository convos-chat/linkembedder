use t::App;
use Test::More;

$t->get_ok('/embed?url=https://twitter.com/jhthorsen/status/434045220116643843')
  ->element_exists('blockquote[class="twitter-tweet"][lang="en"][data-conversation="none"][data-cards="hidden"]')
  ->element_exists('blockquote > a[href="https://twitter.com/jhthorsen/status/434045220116643843"]')
  ->element_exists('script[src="//platform.twitter.com/widgets.js"]');

$t->get_ok('/embed?url=https://twitter.com/jhthorsen')
  ->content_is(q(<a href="https://twitter.com/jhthorsen" target="_blank">https://twitter.com/jhthorsen</a>));

done_testing;
