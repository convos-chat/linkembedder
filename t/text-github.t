use utf8;
use t::App;
use Test::More;

plan skip_all => 'TEST_ONLINE=1 need to be set' unless $ENV{TEST_ONLINE};

my @tests = (
  {
    url   => 'http://git.io/aKhMuA',
    image => '/u/45729',
    h3    => 'Add back compat redirect from /convos to /',
    p     => 'jhthorsen authored Oct 19, 2014',
  },
  {
    url   => 'https://github.com/Nordaaker/convos',
    image => '/u/811887',
    h3    => 'convos - Better group chat',
    p =>
      'Convos is the simplest way to use IRC. It is always online, and accessible to your web browser, both on desktop and mobile. Run in on your home server, or cloud service easily. It can be deployed to Docker-based cloud services, or you can just run it as a normal Mojolicious application, using any of the Deployment Guides.'
  },
  {
    url   => 'https://github.com/Nordaaker/convos/issues/184',
    image => '/u/5526',
    h3    => 'Update install script to use git if available',
    p     => 'marcusramberg opened this Issue Sep 11, 2014 · 1 comment'
  },
  {
    url   => 'https://github.com/Nordaaker/convos/issues/50',
    image => '/u/45729',
    h3    => 'Feature/start backend',
    p     => 'marcusramberg merged 2 commits into master from feature/start-backend 9 months ago'
  },
);

# test caching
splice @tests, 1, 0, $tests[0];

for my $test (@tests) {
  diag $test->{url};

  #last if $test->{url} eq 'https://github.com/Nordaaker/convos';

  $t->get_ok("/embed?url=$test->{url}")->element_exists('.link-embedder.text-html')
    ->element_exists(qq(.link-embedder-media img[src*="$test->{image}"]))
    ->text_is('.link-embedder.text-html > h3', $test->{h3})->text_is('.link-embedder.text-html > p', $test->{p});
}

done_testing;
