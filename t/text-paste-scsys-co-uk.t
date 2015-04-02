use t::App;
use Test::More;

plan skip_all => 'PASTE_SCSYS_ID=470943 need to be set' unless $ENV{PASTE_SCSYS_ID};

$t->get_ok("/embed?url=http://paste.scsys.co.uk/$ENV{PASTE_SCSYS_ID}")

  ->element_exists(qq(div[data-paste-provider="scsys.co.uk"]))
  ->element_exists(qq(div[data-paste-id="$ENV{PASTE_SCSYS_ID}"]))->element_exists(qq(div.link-embedder.text-paste pre))
  ->element_exists(qq(div.link-embedder.text-paste div.paste-meta))
  ->element_exists(
  qq(div.link-embedder.text-paste div.paste-meta a[href="http://paste.scsys.co.uk/$ENV{PASTE_SCSYS_ID}"]))
  ->element_exists(
  qq(div.link-embedder.text-paste div.paste-meta a[href="http://paste.scsys.co.uk/$ENV{PASTE_SCSYS_ID}?tx=on"]))
  ->element_exists_not('script')->text_like('pre', qr{asdasd});

done_testing;
