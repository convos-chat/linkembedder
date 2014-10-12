use t::App;
use Test::More;

$t->get_ok('/embed?url=https://gist.github.com/jhthorsen/6449446')
  ->element_exists(q(div#link_embedder_text_gist_github_1), 'container tag')
  ->element_exists(
  q(script[src="https://gist.github.com/jhthorsen/6449446.json?callback=link_embedder_text_gist_github_1"]),
  'json script tag')
  ->content_like(qr{window\.link_embedder_text_gist_github_1=function}, 'link_embedder_text_gist_github_1()')
  ->content_like(qr{document\.getElementById\('link_embedder_text_gist_github_1'\)\.innerHTML=g\.div}, 'g.div');

$t->get_ok('/embed?url=https://gist.github.com/jhthorsen')
  ->content_is(q(<a href="https://gist.github.com/jhthorsen" target="_blank">https://gist.github.com/jhthorsen</a>));

done_testing;
