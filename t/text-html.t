use t::App;
use Test::More;

$t->app->embed_link->_ua->server->app($t->app);
$t->app->routes->get('/empty' => 'empty');
$t->app->routes->get('/timer-fb' => 'timer-fb');

{
  my $url = $t->ua->server->nb_url->clone->path('/timer-fb')->to_abs;

  $t->get_ok("/embed?url=$url")
    ->element_exists('.link-embedder.text-html')
    ->element_exists('.link-embedder.text-html > .link-embedder-media > img[src="http://timer.thorsen.pm/image/og.png"][alt="Timer"]')
    ->text_is('.link-embedder.text-html > h3', 'Timer')
    ->text_is('.link-embedder.text-html > p', 'Time left: 30s')
    ->text_is('.link-embedder.text-html > .link-embedder-link > a[href="http://timer.thorsen.pm/1413033441/30"]', 'http://timer.thorsen.pm/1413033441/30')
    ;

  $t->get_ok("/embed.json?url=$url")
    ->json_is('/pretty_url', $url)
    ->json_is('/url', $url)
    ->json_is('/media_id', 'http://timer.thorsen.pm/1413033441/30')
    ;
}

{
  my $url = $t->ua->server->nb_url->clone->path('/empty')->to_abs;

  $t->get_ok("/embed?url=$url")
    ->element_exists(qq(a[href="$url"][title="Content-Type: text/html;charset=UTF-8"]))
    ;
}

done_testing;
__DATA__
@@ timer-fb.html.ep
<html>
<head>
  <meta property="og:description" content="Time left: 30s" />
  <meta property="og:determiner" content="a" />
  <meta property="og:image" content="http://timer.thorsen.pm/image/og.png" />
  <meta property="og:title" content="Timer" />
  <meta property="og:url" content="http://timer.thorsen.pm/1413033441/30" />
</head>
<body>
  test123
</body>
</html>

@@ empty.html.ep
<html>
<head>
  <title>Empty</title>
  <meta property="og:description" content="Time left: 30s" />
  <meta property="og:url" content="http://timer.thorsen.pm/1413033441/30" />
</head>
<body>
  test123
</body>
</html>
