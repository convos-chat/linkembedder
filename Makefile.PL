use ExtUtils::MakeMaker;
WriteMakefile(
  NAME => 'Mojolicious::Plugin::LinkEmbedder',
  ABSTRACT_FROM => 'lib/Mojolicious/Plugin/LinkEmbedder.pm',
  VERSION_FROM => 'lib/Mojolicious/Plugin/LinkEmbedder.pm',
  AUTHOR => 'Jan Henning Thorsen <jhthorsen@cpan.org>',
  LICENSE => 'perl',
  PREREQ_PM => {
    'Mojolicious' => '4.30',
  },
  BUILD_REQUIRES => {
    'File::Find' => '1.00',
    'Module::Find' => '0.10',
    'Test::More' => '0.90',
  },
  META_MERGE => {
    resources => {
      license => 'http://dev.perl.org/licenses/',
      homepage => 'https://metacpan.org/release/Mojolicious-Plugin-LinkEmbedder',
      bugtracker => 'http://rt.cpan.org/NoAuth/Bugs.html?Dist=Mojolicious-Plugin-LinkEmbedder',
      repository => 'https://github.com/jhthorsen/mojolicious-plugin-linkembedder',
    },
  },
  test => {
    TESTS => 't/*.t',
  },
);
