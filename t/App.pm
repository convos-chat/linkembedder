package t::App;

use strict;
use warnings;
use Mojolicious;
use Test::Mojo;
use Test::More;

my $t;

sub make_app {
  my $class = shift;
  my $app   = Mojolicious->new;

  $app->plugin(LinkEmbedder => {route => '/embed'});

  Test::Mojo->new($app);
}

sub import {
  my $class  = shift;
  my $caller = caller;

  strict->import;
  warnings->import;

  no strict 'refs';
  *{"$caller\::t"} = \$class->make_app;
}

1;
