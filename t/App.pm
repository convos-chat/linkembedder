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
      my $self = shift;
      my $link = $self->embed_link($self->param('url'));

      $self->respond_to(
        json => {
          json => {
            is_media => $link->is_media,
            is_movie => $link->is_movie,
            media_id => $link->media_id,
            url => $link->url->to_string,
          },
        },
        any => { text => "$link" },
      );
    };

    get '/rebless' => sub {
      my $self = shift->render_later;
      my $link = $self->embed_link($self->param('url'));

      $link->rebless(sub {
        $self->render(text => $link->to_embed);
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
