use t::App;
use Test::More;

{
  $t->get_ok('/embed?url=http://google.com')
    ->content_is(q(<a href="http://google.com" target="_blank">http://google.com</a>));
    ;

  $t->get_ok('/embed.json?url=http://google.com')
    ->json_is('/is_media', 0)
    ->json_is('/is_movie', 0)
    ->json_is('/media_id', '')
    ;
}

done_testing;
