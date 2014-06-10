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
  <script>
    // window.link_embedder_text_gist_github_styled = 1;
  </script>
  <style>
    iframe { width: 100%; border: 0; }
  </style>
</head>
<body>
%= content
</body>
</html>
