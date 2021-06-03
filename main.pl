#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';

use LinkEmbedder;

my $embedder = LinkEmbedder->new(force_secure => 1);

# In some cases, you have to set a proper user_agent to get complete
# pages. This is done automatically by $embedder->serve()
$embedder->ua->transactor->name("Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.77 Safari/537.36");

$embedder->get_p("https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4")->then(sub {
#$embedder->get_p("https://dl8.webmfiles.org/big-buck-bunny_trailer.webm")->then(sub {
#$embedder->get_p("https://www.learningcontainer.com/mp4-sample-video-files-download/")->then(sub {
    my $link = shift;
    print $link->html;
})->wait;

