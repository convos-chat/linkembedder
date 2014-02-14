package
  t::App;

use strict;
use warnings;
use Test::Mojo;
use Test::More;

my $t;

sub make_app {
  my $class = shift;

  eval <<'  APP' or die $@;
    use Mojolicious::Lite;
    plugin LinkEmbedder => { route => '/embed' };
    app->start;
  APP

  Test::Mojo->new;
}

sub import {
  my $class = shift;
  my $caller = caller;

  strict->import;
  warnings->import;

  no strict 'refs';
  *{ "$caller\::t" } = \ $class->make_app;
}

1;
