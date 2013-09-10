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
    plugin 'LinkEmbedder';

    get '/embed' => sub {
      my $self = shift->render_later;
      
      $self->embed_link($self->param('url'), sub {
        my($self, $link) = @_;
        $self->respond_to(
          json => {
            json => {
              media_id => $link->media_id,
              pretty_url => $link->pretty_url->to_string,
              url => $link->url->to_string,
            },
          },
          any => { text => "$link" },
        );
      });
    };

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
