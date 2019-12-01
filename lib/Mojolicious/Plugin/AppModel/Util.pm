package Mojolicious::Plugin::AppModel::Util;

use Mojo::Util qw(camelize decamelize);

use Exporter 'import';

our @EXPORT_OK = qw(migrations model_name module_name print_levels);

sub migrations {
  my $model = shift;
  my $name = model_name($model);
  $model->backend->migrations->name($name)->from_data(ref $model, 'migrations');
}

sub model_name {
  my $class = ref $_[-1] || $_[-1];
  decamelize((split /::/, $class)[-1]);
}

sub module_name {
  join '::', $_[-2], camelize($_[-1]);
}

sub print_levels {
  local $_ = shift;
  my $name = model_name($_);
  my $m = migrations($_);
  printf "Model: %16s | Latest: %5s | Active: %5s\n",
         $name, $m->latest, $m->active;
}

1;

=encoding utf8

=head1 NAME

Mojolicious::Plugin::AppModel::Util - AppModel utility functions

=head1 SYNOPSIS

  use Mojolicious::Plugin::AppModel::Util qw(model_name);

  say model_name($self);

=head1 DESCRIPTION

L<Mojo::Util> provides utility functions for L<Mojolicious::Plugin::AppModel>.

=head1 FUNCTIONS

L<Mojolicious::Plugin::AppModel::Util> implements the following functions, which
can be imported individually.

=head2 migrations

  my $migrations = migrations($model);

Backend migrations object for the data from the embedded file named
"migrations" of the specified object model.

  # reset model for $model
  migrations($model)->migrate(0)->migrate;

=head2 model_name

  my $name = model_name $model;

Convert a class name to C<snake_case>.

  # "users"
  model_name 'App::Model::Users';

=head2 print_levels

  print_levels($model);

Print model name and latest and active model versions.

  # Model: model_name | Latest: 2 | Active: 1
  print_levels('ModelName');
  
=head1 SEE ALSO

L<Mojolicious::Plugin::AppModel>, L<Mojolicious>, L<Mojolicious::Guides>,
L<https://mojolicious.org>.

=cut