use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
  NAME         => 'Mojolicious::Plugin::AppModel',
  VERSION_FROM => 'lib/Mojolicious/Plugin/AppModel.pm',
  ABSTRACT     => 'A Developer\'s starter model for Mojolicious Apps',
  AUTHOR       => 'Stefan Adams <sadams@cpan.org>',
  LICENSE      => 'artistic_2',
  META_MERGE   => {
    dynamic_config => 0,
    'meta-spec'    => {version => 2},
    no_index       => {
      directory => [qw(t)],
    },
    prereqs   => {runtime => {requires => {perl => '5.010001'}}},
    resources => {
      bugtracker => {web => 'https://github.com/stefanadams/mojolicious-plugin-appmodel/issues'},
      homepage   => 'https://stefan.adams.fm',
      license    => ['http://www.opensource.org/licenses/artistic-license-2.0'],
      repository => {
        type => 'git',
        url  => 'https://github.com/stefanadams/mojolicious-plugin-appmodel.git',
        web  => 'https://github.com/stefanadams/mojolicious-plugin-appmodel',
      },
      x_IRC => 'irc://irc.freenode.net/#mojo'
    },
  },
  PREREQ_PM    => {
    'Mojolicious'  => '8.26',
    'Mojo::SQLite' => '3.00',
  },
  #EXE_FILES    => ['script/*'],
  test         => {TESTS => 't/*.t'}
);
