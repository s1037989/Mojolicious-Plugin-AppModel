package Mojolicious::Plugin::AppModel::Command::models::reset;
use Mojo::Base 'Mojolicious::Command';

use Mojo::Util 'getopt';

use Mojolicious::Plugin::AppModel::Util qw(migrations print_levels);

use Term::ReadKey;

has description => 'Reset models using backend\'s migrations functionality';
has usage       => sub { shift->extract_usage };

sub run {
  my ($self, @args) = @_;
  
  my $key = '';
  getopt \@args,
    'dry-run|n' => \my $dry_run,
    'yes|y'  => sub { $key = 'y' };
  $self->_dry_run and exit if $dry_run;

  print qq{THIS WILL WIPE ALL DATA FROM THE DATABASE.\n}.
        qq{Are you sure you want to continue? [y/N] } unless $key eq 'y';

  ReadMode 4; # Turn off controls keys
  while ( $key !~ /^[yn\n]$/i ) {
    1 while (not defined ($key = ReadKey(-1)));
  }
  say '';
  ReadMode 0; # Reset tty mode before exiting

  $self->_reset_model if lc($key) eq 'y';
}

sub _dry_run {
  my $self = shift;
  $self->app->models->each(sub{
    my $m = migrations($_);
    say $m->sql_for($m->active, 0);
    say $m->sql_for(0, $m->latest);
  });
}

sub _reset_model {
  my $self = shift;
  $self->app->log->info("Resetting model");
  $self->app->models->each(sub{
    migrations($_)->migrate(0)->migrate and print_levels($_);
  });
}

1;

=encoding utf8

=head1 NAME

Mojolicious::Plugin::AppModel::Command::models::reset - Reset Models

=head1 SYNOPSIS

  Usage: APPLICATION models reset

    ./myapp.pl models reset [OPTIONS]

  Options:
    -n, --dry_run Display the SQL statements that will be executed without
                  actually doing anything
    -y, --yes     Confirm to proceed with reset without prompting

=head1 DESCRIPTION

L<Mojolicious::Plugin::AppModel::Command::models::reset> resets the MVC
L<Mojolicious::Plugin::AppModel>s using the backend's migrations functionality.

=head1 ATTRIBUTES

L<Mojolicious::Plugin::AppModel::Command::models::reset> inherits all
attributes from L<Mojolicious::Command> and implements the following new ones.

=head2 description

  my $description = $reset->description;
  $reset          = $reset->description('Foo');

Short description of this command, used for the command list.

=head2 usage

  my $usage = $reset->usage;
  $reset    = $reset->usage('Foo');

Usage information for this command, used for the help screen.

=head1 METHODS

L<Mojolicious::Plugin::AppModel::Command::models::reset> inherits all methods
from L<Mojolicious::Command> and implements the following new ones.

=head2 run

  $reset->run(@ARGV);

Run this command.

=head1 SEE ALSO

L<Mojolicious::Plugin::AppModel>, L<Mojolicious::Guides>,
L<https://mojolicious.org>.

=cut