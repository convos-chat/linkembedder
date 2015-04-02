use t::App;
use Test::More;

plan skip_all => 'TEST_ONLINE=1 need to be set' unless $ENV{TEST_ONLINE};

$ENV{IX_ID} ||= 'hff';

$t->get_ok('/embed?url=http://ix.io/hff')->element_exists(qq(div[data-paste-provider="ix.io"]))
  ->element_exists(qq(div[data-paste-id="$ENV{IX_ID}"]))->element_exists(qq(div.link-embedder.text-paste pre))
  ->element_exists(qq(div.link-embedder.text-paste div.paste-meta))
  ->element_exists(qq(div.link-embedder.text-paste div.paste-meta a[href="http://ix.io/$ENV{IX_ID}"]))
  ->element_exists(qq(div.link-embedder.text-paste div.paste-meta a[href="http://ix.io/$ENV{IX_ID}/"]));

done_testing;
