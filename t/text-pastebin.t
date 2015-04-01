use t::App;
use Test::More;

plan skip_all => 'TEST_ONLINE=1 need to be set' unless $ENV{TEST_ONLINE};

$t->get_ok("/embed?url=http://pastebin.com/JgcQLXyh")->element_exists('pre')
  ->element_exists('pre.link-embedder.text-paste')->element_exists_not('script')->text_like('pre', qr{from_json.*try}s);

done_testing;
