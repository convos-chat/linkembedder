use Mojo::Base -strict;
use Test::More;
use LinkEmbedder;

my $embedder = LinkEmbedder->new;
my $link
  = $embedder->get(
  'https://www.google.no/maps/place/Oslo,+Norway/@59.8937806,10.6450355,11z/data=!3m1!4b1!4m5!3m4!1s0x46416e61f267f039:0x7e92605fd3231e9a!8m2!3d59.9138688!4d10.7522454'
  );
isa_ok($link, 'LinkEmbedder::Link::Google');
is_deeply $link->TO_JSON,
  {
  cache_age     => 0,
  html          => html(),
  provider_name => 'Google',
  provider_url  => 'https://google.com',
  title         => 'Oslo, Norway',
  type          => 'rich',
  url =>
    'https://www.google.no/maps/place/Oslo,+Norway/@59.8937806,10.6450355,11z/data=!3m1!4b1!4m5!3m4!1s0x46416e61f267f039:0x7e92605fd3231e9a!8m2!3d59.9138688!4d10.7522454',
  version => '1.0',
  },
  'json'
  or note $link->_dump;

done_testing;

sub html {
  return <<'HERE';
<iframe width="600" height="400" style="border:0;width:100%" frameborder="0" allowfullscreen
  src="https://www.google.com/maps?q=Oslo%2C%2BNorway%20%4059.8937806%2C10.6450355&output=embed">
</iframe>
HERE
}
