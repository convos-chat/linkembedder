use t::App;
use Test::More;

my @types = qw( video/mpeg video/mpeg video/quicktime video/mp4 video/ogg );
for my $ext (qw( mpg mpeg mov mp4 ogv )) {
  my $type = shift @types;
  $t->get_ok("/embed?url=http://video.thinkninja.com/grumpify_banner.$ext")
    ->content_is(qq(<video width="640" height="390"><source src="http://video.thinkninja.com/grumpify_banner.$ext" type="$type"><p class="alert">Your browser does not support the video tag.</p></video>));
    ;
}

{
  $t->get_ok("/embed.json?url=http://video.thinkninja.com/grumpify_banner.ogv")
    ->json_is('/media_id', '')
    ->json_is('/pretty_url', 'http://video.thinkninja.com/grumpify_banner.ogv')
    ->json_is('/url', 'http://video.thinkninja.com/grumpify_banner.ogv')
    ;
}

done_testing;
