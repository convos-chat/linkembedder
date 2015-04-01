use t::App;
use Test::More;

plan skip_all => 'PASTE_SCSYS_LINK= need to be set' unless $ENV{PASTE_SCSYS_LINK};

$t->get_ok("/embed?url=$ENV{PASTE_SCSYS_LINK}")->element_exists('pre')->element_exists('pre.link-embedder.text-paste')
  ->element_exists_not('script')->text_like('pre', qr{asdasd});

done_testing;
