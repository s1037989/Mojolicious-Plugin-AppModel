package Mojolicious::Plugin::AppModel::Command::models::migrate;
use Mojo::Base 'Mojolicious::Command';

use Mojo::Util 'getopt';

use Mojolicious::Plugin::AppModel::Util qw(migrations print_levels);

use Term::ReadKey;

has description => 'Migrate models using backend\'s migrations functionality';
has usage       => sub { shift->extract_usage };

sub run {
  my ($self, @args) = @_;
  
  my $key = '';
  getopt \@args,
    'dry-run|n' => \my $dry_run,
    'yes|y'  => sub { $key = 'y' };
  my $level = shift @args;
  
  $self->_dry_run($level) and exit if $dry_run;

  print qq{THIS WILL WIPE ALL DATA FROM THE DATABASE.\n}.
        qq{Are you sure you want to continue? [y/N] } unless $key eq 'y';

  ReadMode 4; # Turn off controls keys
  while ( $key !~ /^[yn\n]$/i ) {
    1 while (not defined ($key = ReadKey(-1)));
  }
  say '';
  ReadMode 0; # Reset tty mode before exiting

  $self->_migrate_model($level) if lc($key) eq 'y';
}

sub _dry_run {
  my ($self, $level) = @_;
  $self->app->models->each(sub{
    my $m = migrations($_);
    say $m->sql_for($m->active, $level // $m->latest);
  });
}

sub _migrate_model {
  my ($self, $level) = @_;
  $self->app->log->info(sprintf 'Migrating model to %s',
                        $level ? "level $level" : 'latest level');
  $self->app->models->each(sub{
    my $m = migrations($_);
    $m->migrate($level // $m->latest) and print_levels($_);
  });
}

1;

=encoding utf8

=head1 NAME

Mojolicious::Plugin::AppModel::Command::models::migrate - Migrate Models

=head1 SYNOPSIS

  Usage: APPLICATION models migrate

    ./myapp.pl models migrate [OPTIONS] [LEVEL]

  If LEVEL is not specified, the latest level will be used.

  Options:
    -n, --dry_run Display the SQL statements that will be executed without
                  actually doing anything
    -y, --yes     Confirm to proceed with migrate without prompting

=head1 DESCRIPTION

L<Mojolicious::Plugin::AppModel::Command::models::migrate> migrates the MVC
L<Mojolicious::Plugin::AppModel> using the backend's migrations functionality.

=head1 ATTRIBUTES

L<Mojolicious::Plugin::AppModel::Command::models::migrate> inherits all attributes
from L<Mojolicious::Command> and implements the following new ones.

=head2 description

  my $description = $migrate->description;
  $migrate        = $migrate->description('Foo');

Short description of this command, used for the command list.

=head2 usage

  my $usage = $migrate->usage;
  $migrate  = $migrate->usage('Foo');

Usage information for this command, used for the help screen.

=head1 METHODS

L<Mojolicious::Plugin::AppModel::Command::models::migrate> inherits all methods
from L<Mojolicious::Command> and implements the following new ones.

=head2 run

  $migrate->run(@ARGV);

Run this command.

=head1 SEE ALSO

L<Mojolicious::Plugin::AppModel>, L<Mojolicious::Guides>,
L<https://mojolicious.org>.

=cut