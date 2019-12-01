package Mojolicious::Plugin::Model::Command::model::reset;
use Mojo::Base 'Mojolicious::Command';

use Mojo::Util 'getopt';

use Term::ReadKey;

has description => 'Reset model using backend\'s migrations functionality';
has usage       => sub { shift->extract_usage };

sub run {
  my ($self, @args) = @_;
  
  my $key = '';
  getopt \@args,
    'yes|y'  => sub { $key = 'y' };

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

sub _reset_model {
  my $self = shift;
  $self->app->log->info("Resetting model");
  $self->app->migrations->each(sub{say $_->migrate(0)->migrate});
}

1;

=encoding utf8

=head1 NAME

Mojolicious::Plugin::Model::Command::model::reset - Reset Model

=head1 SYNOPSIS

  Usage: APPLICATION model reset

    ./myapp.pl model reset [OPTIONS]

  Options:
    -y, --yes   Confirm to proceed with reset without prompting

=head1 DESCRIPTION

L<Mojolicious::Plugin::Model::Command::model::reset> resets the MVC
L<Mojolicious::Plugin::Model> using the backend's migrations functionality.

=head1 ATTRIBUTES

L<Mojolicious::Plugin::Model::Command::model::reset> inherits all attributes
from L<Mojolicious::Command> and implements the following new ones.

=head2 description

  my $description = $reset->description;
  $reset            = $reset->description('Foo');

Short description of this command, used for the command list.

=head2 usage

  my $usage = $reset->usage;
  $reset      = $reset->usage('Foo');

Usage information for this command, used for the help screen.

=head1 METHODS

L<Mojolicious::Plugin::Model::Command::model::reset> inherits all methods from
L<Mojolicious::Command> and implements the following new ones.

=head2 run

  $reset->run(@ARGV);

Run this command.

=head1 SEE ALSO

L<Mojolicious::Plugin::Model>, L<Mojolicious::Guides>,
L<https://mojolicious.org>.

=cut