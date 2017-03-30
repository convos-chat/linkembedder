use Mojo::Base -strict;
use Test::More;
use LinkEmbedder;

plan skip_all => 'TEST_ONLINE=1' unless $ENV{TEST_ONLINE};

my $embedder = LinkEmbedder->new;
my $link     = $embedder->get('https://www.instagram.com/p/BQzeGY0gd63');
isa_ok($link, 'LinkEmbedder::Link::oEmbed');

my $json = $link->TO_JSON;

like delete($json->{html}), qr{instagram-media}, 'html';

is_deeply $json,
  {
  author_name      => 'thuygia',
  author_url       => 'https://www.instagram.com/thuygia',
  cache_age        => 0,
  provider_name    => 'Instagram',
  provider_url     => 'https://www.instagram.com',
  thumbnail_height => '640',
  thumbnail_url =>
    'https://scontent-arn2-1.cdninstagram.com/t51.2885-15/s640x640/sh0.08/e35/16585734_1256460307782370_723156494169669632_n.jpg',
  thumbnail_width => '640',
  title           => "\x{2764}Designing products people love by \@scotthurff",
  type            => 'rich',
  url             => 'https://www.instagram.com/p/BQzeGY0gd63',
  version         => '1.0',
  width           => '658',
  },
  'json'
  or note $link->_dump;

done_testing;
