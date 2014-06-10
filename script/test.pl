#!/usr/bin/env perl
use Mojolicious::Lite;
use lib 'lib';
app->defaults(layout => 'default');
plugin LinkEmbedder => { route => '/embed' };
app->start;
__DATA__
@@ layouts/default.html.ep
<html>
<head>
  <title>Test embed code for <%= param('url') || 'missing ?url=' %></title>
</head>
<body>
%= content
</body>
</html>
