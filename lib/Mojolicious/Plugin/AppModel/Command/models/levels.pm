package Mojolicious::Plugin::AppModel::Command::models::levels;
use Mojo::Base 'Mojolicious::Command';

use Mojolicious::Plugin::AppModel::Util 'print_levels';

has description => 'Display models\' levels using backend\'s migrations '.
                   'functionality';
has usage       => sub { shift->extract_usage };

sub run {
  my ($self, @args) = @_;
  
  $self->app->models->each(sub{ print_levels($_) });
}

1;

=encoding utf8

=head1 NAME

Mojolicious::Plugin::AppModel::Command::models::levels - Display Model levels

=head1 SYNOPSIS

  Usage: APPLICATION models levels

    ./myapp.pl models levels

  Options:
    None

=head1 DESCRIPTION

L<Mojolicious::Plugin::AppModel::Command::models::levels> displays levels of the
MVC L<Mojolicious::Plugin::AppModel>s using the backend's migrations functionality.

=head1 ATTRIBUTES

L<Mojolicious::Plugin::AppModel::Command::models::levels> inherits all attributes
from L<Mojolicious::Command> and implements the following new ones.

=head2 description

  my $description = $levels->description;
  $levels         = $levels->description('Foo');

Short description of this command, used for the command list.

=head2 usage

  my $usage = $levels->usage;
  $levels   = $levels->usage('Foo');

Usage information for this command, used for the help screen.

=head1 METHODS

L<Mojolicious::Plugin::AppModel::Command::models::levels> inherits all methods
from L<Mojolicious::Command> and implements the following new ones.

=head2 run

  $levels->run(@ARGV);

Run this command.

=head1 SEE ALSO

L<Mojolicious::Plugin::AppModel>, L<Mojolicious::Guides>,
L<https://mojolicious.org>.

=cut