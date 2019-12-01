# Mojolicious-Plugin-AppModel

A Developer's starter model for Mojolicious Apps.

# Synopsis

  # Full App
  $self->plugin('AppModel');
  my $id = $self->model('users')->add({name => 'Name', email => 'email'});
  say $self->users->get($id);

  # Lite App
  plugin 'AppModel';
  my $id = app->model('users')->add({name => 'Name', email => 'email'});
  say app->users->get($id);

# Description

This plugin will use or generate model classes in these ways:
