use Mojo::Base -strict;
use Test::Deep;
use Test::More;
use LinkEmbedder;

plan skip_all => 'TEST_ONLINE=1' unless $ENV{TEST_ONLINE};

my $embedder = LinkEmbedder->new;
my $link;

$embedder->get_p('https://www.dropbox.com/s/nhjyi76so7b93lv/IMG_2394.jpg?dl=0')->then(sub { $link = shift })->wait;
ok $link->{thumbnail_url}, 'got thumbnail_url';

done_testing;
