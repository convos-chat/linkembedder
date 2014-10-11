use t::App;
use Test::More;

{
  $t->get_ok('/embed?url=http://google.com')
    ->text_is('a[href="http://google.com"][title="Content-Type: text/html; charset=UTF-8"]', 'http://google.com');

  $t->get_ok('/embed.json?url=http://google.com')->json_is('/media_id', 'http://google.com')
    ->json_is('/pretty_url', 'http://google.com')->json_is('/url', 'http://google.com');
}

done_testing;
