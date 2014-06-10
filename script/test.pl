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
  <style>
    iframe { width: 100%; border: 0; }
  </style>
</head>
<body>
%= content
</body>
</html>
