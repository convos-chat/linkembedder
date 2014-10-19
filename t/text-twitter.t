use t::App;
use Test::More;

$t->get_ok('/embed?url=https://twitter.com/jhthorsen/status/434045220116643843')
  ->element_exists(
  'div.link-embedder.text-twitter > blockquote[class="twitter-tweet"][lang="en"][data-conversation="none"][data-cards="hidden"]'
  )
  ->element_exists(
  'div.link-embedder.text-twitter > blockquote > a[href="https://twitter.com/jhthorsen/status/434045220116643843"]')
  ->element_exists('div.link-embedder.text-twitter > script[src="//platform.twitter.com/widgets.js"]');

$t->get_ok('/embed?url=https://twitter.com/jhthorsen')
  ->text_is('a[href="https://twitter.com/jhthorsen"][target="_blank"]', 'https://twitter.com/jhthorsen');

done_testing;
