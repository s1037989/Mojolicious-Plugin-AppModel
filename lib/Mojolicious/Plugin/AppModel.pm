package Mojolicious::Plugin::AppModel;
use Mojo::Base 'Mojolicious::Plugin';

use Mojo::Collection;
use Mojo::Loader qw(find_modules load_class);
use Mojo::SQLite;

use Mojolicious::Plugin::AppModel::Util qw(model_name module_name);

use Scalar::Util;

use constant DEBUG      => $ENV{APPMODEL_DEBUG} || 0;
use constant NO_MIGRATE => $ENV{APPMODEL_NO_MIGRATE} || 0;

our $VERSION = '0.01';

has 'app';
has models => sub { Mojo::Collection->new };

sub register {
  my ($self, $app, $config) = @_;
  $self->app($app);
  my $backend = $config->{backend} // sub { Mojo::SQLite->new('sqlite:appmodel.db') };
  my $namespace = $config->{namespace} // join '::', ((split /::/, ref $app)[0]), 'Model';

  push @{$app->commands->namespaces}, 'Mojolicious::Plugin::AppModel::Command';
  $app->helper(backend => sub {
    my $backend_obj = $backend->($app);
    return $self->{"backend.obj"} if $self->{"backend.obj"};
    eval _log_role($backend_obj);
    $self->{"backend.obj"} ||= $backend_obj->with_roles('+Log')->log(shift->log)
  });
  $app->helper(models => sub { $self->models });
  $app->helper(model  => sub {
    my ($c, $name) = @_;
    my $module = module_name($namespace, $name);
    return $self->{"model.$name"} if $self->{"model.$name"};
    my $e = load_class $module;
    warn qq{Loading "$module" failed: $e} and next if ref $e;
    $self->_autoload($module);
    $self->_register($module);
    $self->_migrate($module => $app->config('model_level'));
    return $c->$name;
  });

  for my $module (find_modules $namespace) {
    my $e = load_class $module;
    warn qq{Loading "$module" failed: $e} and next if ref $e;
    $self->_autoload($module);
    $self->_register($module);
    $self->_migrate($module => $app->config('model_level'));
  }
}

sub _autoload {
  my ($self, $module) = @_;
  return unless $self->app->mode eq 'development';
  my $eval = <<'EOF';
package $module;
use Mojo::Base -base;

use Mojo::JSON 'j';

has 'backend';

sub add {
  my $self = shift;
  $self->backend->log->debug('add $module');
  $self->backend->db->insert('posts', {doc => j(shift)})->last_insert_id;
}

sub all {
  my $self = shift;
  $self->backend->log->debug('all $module');
  $self->backend->db->select('uploads')->hashes->to_array;
}

sub get {
  my $self = shift;
  $self->backend->log->debug('get $module');
  $self->backend->db->select('posts', ['doc'], {id => shift})->expand(json => 'doc')->hash->{doc};
}

sub AUTOLOAD {
  my $self = shift;

  my ($package, $method) = our $AUTOLOAD =~ /^(.+)::(.+)$/;
  $self->backend->log->debug("$method $module");

  #return bless {}, $package if $method eq 'new';
  return pop;
}

1;
EOF
  $eval =~ s/\$module/$module/g;
  eval $eval;
  return $@;
}

sub _log_role {
  my $class = ref $_[-1] || $_[-1];
  $class = join '::', $class, 'Role::Log';
  my $code = <<EOF;
package $class;
use Mojo::Base -role;
has 'log';
1;
EOF
  return $code;
}

sub _register {
  my ($self, $module) = @_;
  my $name = model_name($module);
  $self->app->log->debug(qq{Registering "$name"}) if DEBUG;
  $self->app->helper($name => sub {
    $self->{"model.$name"} ||= $module->new(backend => $self->app->backend);
  });
  push @{$self->models}, $self->app->$name;
}

sub _migrate {
  my ($self, $module, $level) = @_;
  return if NO_MIGRATE;
  return unless $self->app->backend->can('migrations');

  my $name = model_name($module);
  $self->app->log->debug(qq{Migrating "$name" from "$module#migrations"}) if DEBUG;
  my $m = $self->app->backend->migrations->name($name)->from_data($module, 'migrations');
  $self->_level1($name);
  $m->migrate($level // $m->latest);
}

sub _level1 {
  my ($self, $name) = @_;
  my $backend = lc($self->app->backend->db->dbh->{Driver}->{Name});
  $backend = "_level1_$backend";
  $self->can($backend) or return;
  $self->$backend($name);
}

sub _level1_pg {
  my ($self, $name) = @_;
  $self->app->backend->migrations->{migrations}->{up}  ->{1} = qq(create table $name (id serial primary key, doc json););
  $self->app->backend->migrations->{migrations}->{down}->{1} = qq(drop table $name;);
}

sub _level1_sqlite {
  my ($self, $name) = @_;
  $self->app->backend->migrations->{migrations}->{up}  ->{1} = qq(create table $name (id integer primary key autoincrement, doc json););
  $self->app->backend->migrations->{migrations}->{down}->{1} = qq(drop table $name;);
}

1;

__END__

=encoding utf8

=head1 NAME

Mojolicious::Plugin::AppModel - Mojolicious Plugin

=head1 SYNOPSIS

  # Mojolicious
  $self->plugin('AppModel');

  # Mojolicious::Lite
  plugin 'AppModel';

=head1 DESCRIPTION

L<Mojolicious::Plugin::AppModel> is a L<Mojolicious> plugin.

=head1 METHODS

L<Mojolicious::Plugin::AppModel> inherits all methods from
L<Mojolicious::Plugin> and implements the following new ones.

=head2 register

  $plugin->register(Mojolicious->new);

Register plugin in L<Mojolicious> application.

=head1 SEE ALSO

L<Mojolicious>, L<Mojolicious::Guides>, L<https://mojolicious.org>.

=cut
