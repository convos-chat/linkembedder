use t::App;
use Test::More;

plan skip_all => 'TEST_ONLINE=1 need to be set' unless $ENV{TEST_ONLINE};

$ENV{PASTEBIN_ID} ||= 'JgcQLXyh';

$t->get_ok("/embed?url=http://pastebin.com/$ENV{PASTEBIN_ID}")
  ->element_exists(qq(div[data-paste-provider="pastebin.com"]))
  ->element_exists(qq(div[data-paste-id="$ENV{PASTEBIN_ID}"]))->element_exists(qq(div.link-embedder.text-paste pre))
  ->element_exists(qq(div.link-embedder.text-paste div.paste-meta))
  ->element_exists(
  qq(div.link-embedder.text-paste div.paste-meta a[href="http://pastebin.com/raw.php?i=$ENV{PASTEBIN_ID}"]))
  ->element_exists(qq(div.link-embedder.text-paste div.paste-meta a[href="http://pastebin.com/$ENV{PASTEBIN_ID}"]))
  ->element_exists_not('script')->text_like('pre', qr{from_json.*try}s);

done_testing;
