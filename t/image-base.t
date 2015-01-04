use t::App;
use Test::More;

$t->get_ok('/embed?url=http://catoverflow.com/cats/r4cIt4z.gif')
  ->content_is(q(<img src="http://catoverflow.com/cats/r4cIt4z.gif" alt="http://catoverflow.com/cats/r4cIt4z.gif">));

if ($ENV{TEST_ONLINE}) {
  $t->get_ok('/embed?url=https://gravatar.com/avatar/806800a3aeddbad6af673dade958933b')
    ->content_is(
    q(<img src="https://gravatar.com/avatar/806800a3aeddbad6af673dade958933b" alt="https://gravatar.com/avatar/806800a3aeddbad6af673dade958933b">)
    );
}

done_testing;
