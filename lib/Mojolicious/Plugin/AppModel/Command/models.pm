package Mojolicious::Plugin::AppModel::Command::models;
use Mojo::Base 'Mojolicious::Commands';

has description => 'An MVC Model framework for Mojolicious';
has hint        => <<EOF;

See 'APPLICATION models help COMMAND' for more information on a specific
command.
EOF
has message    => sub { shift->extract_usage . "\nCommands:\n" };
has namespaces => sub { ['Mojolicious::Plugin::AppModel::Command::models'] };

sub help { shift->run(@_) }

1;

=encoding utf8

=head1 NAME

Mojolicious::Plugin::AppModel::Command::models - Model command

=head1 SYNOPSIS

  Usage: APPLICATION models COMMAND [OPTIONS]

=head1 DESCRIPTION

L<Mojolicious::Plugin::AppModel::Command::models> lists available L<models>
commands.

=head1 ATTRIBUTES

L<Mojolicious::Plugin::AppModel::Command::models> inherits all attributes from
L<Mojolicious::Commands> and implements the following new ones.

=head2 description

  my $description = $model->description;
  $model         = $model->description('Foo');

Short description of this command, used for the command list.

=head2 hint

  my $hint = $model->hint;
  $model  = $model->hint('Foo');

Short hint shown after listing available L<models> commands.

=head2 message

  my $msg = $model->message;
  $model = $model->message('Bar');

Short usage message shown before listing available L<models> commands.

=head2 namespaces

  my $namespaces = $model->namespaces;
  $model        = $model->namespaces(['MyApp::Command::models']);

Namespaces to search for available L<models> commands, defaults to
L<Mojolicious::Plugin::AppModel::Command::models>.

=head1 METHODS

L<Mojolicious::Plugin::AppModel::Command::models> inherits all methods from
L<Mojolicious::Commands> and implements the following new ones.

=head2 help

  $model->help('app');

Print usage information for L<models> command.

=head1 SEE ALSO

L<Model>, L<Mojolicious::Guides>, L<https://mojolicious.org>.

=cut