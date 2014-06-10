use t::App;
use Test::More;

$t->get_ok('/embed?url=https://gist.github.com/jhthorsen/6449446')
  ->element_exists("div#link_embedder_text_gist_github_1", 'div added')
  ->content_like(qr{createElement\('iframe'\);}, 'got iframe')
  ->content_like(qr{writeln\('<html><body style="padding:0;margin:0" onload="parent\.linkembedderiframesize1\(document\.body\.scrollHeight\)"><script src="https://gist\.github\.com/jhthorsen/6449446\.js"><\\/script><\\/body><\\/html>'\);}, 'writeln')
  ;

$t->get_ok('/embed?url=https://gist.github.com/jhthorsen')
  ->content_is(q(<a href="https://gist.github.com/jhthorsen" target="_blank">https://gist.github.com/jhthorsen</a>))
  ;

done_testing;
