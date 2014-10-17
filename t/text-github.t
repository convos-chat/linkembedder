use utf8;
use t::App;
use Test::More;

plan skip_all => 'TEST_ONLINE=1 need to be set' unless $ENV{TEST_ONLINE};

my @tests = (
  {
    path => 'convos',
    h3   => 'convos - Better group chat',
    p =>
      'Convos is the simplest way to use IRC. It is always online, and accessible to your web browser, both on desktop and mobile. Run in on your home server, or cloud service easily. It can be deployed to Docker-based cloud services, or you can just run it as a normal Mojolicious application, using any of the Deployment Guides.'
  },
  {
    path => 'convos/issues/1',
    h3   => 'Make a fork that use Mandel instead of Mojo::Redis as backend',
    p    => 'jhthorsen opened this Issue Dec 8, 2013 · 5 comments'
  },
  {
    path => 'convos/issues/50',
    h3   => 'Feature/start backend',
    p    => 'marcusramberg merged 2 commits into master from feature/start-backend 9 months ago'
  },
);

for my $test (@tests) {
  my $url = "https://github.com/Nordaaker/$test->{path}";
  diag $url;

  $t->get_ok("/embed?url=$url")->element_exists('.link-embedder.text-html')
    ->text_is('.link-embedder.text-html > h3', $test->{h3})->text_is('.link-embedder.text-html > p', $test->{p});
}

done_testing;
