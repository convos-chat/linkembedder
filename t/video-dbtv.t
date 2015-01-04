use t::App;
use Test::More;

plan skip_all => 'TEST_ONLINE=1 need to be set' unless $ENV{TEST_ONLINE};

$t->get_ok('/embed?url=http://beta.dbtv.no/3186954129001?vid%3D3186954129001%26ct%3Dtrendingnow%233186954129001')
  ->content_like(
  qr{<iframe src="http://\w+\.dbtv\.no/player/3186954129001\?autoplay=false" frameborder="0" width="980" height="551" scrolling="no" marginheight="0" marginwidth="0"></iframe>}
  );

$t->get_ok('/embed.json?url=http://beta.dbtv.no/3186954129001?vid%3D3186954129001%26ct%3Dtrendingnow%233186954129001')
  ->json_is('/media_id', '3186954129001')
  ->json_like('/pretty_url', qr{http://\w+\.dbtv\.no/3186954129001\?vid=3186954129001})
  ->json_like('/url',        qr{http://\w+\.dbtv\.no/3186954129001\?vid=3186954129001&ct=trendingnow});

done_testing;
