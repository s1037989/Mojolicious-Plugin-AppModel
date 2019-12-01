use Mojo::Base -strict;

use Test::More;
use Mojolicious::Lite;
use Test::Mojo;

use Mojo::SQLite;

use constant DEBUG => $ENV{APPMODEL_TESTS_DEBUG} || 0;

use lib 't/lib';

plugin 'AppModel' => {backend => sub { Mojo::SQLite->new }};

my $t = Test::Mojo->new;
$t->app->backend->log->level('debug') if DEBUG;
is $t->app->model('made_up')->super_made_up('whatever', 'expect this'), 'expect this', 'successful mock super made_up';
is $t->app->made_up->make_believe('this', 'dpes not exist'), 'dpes not exist', 'successful mock make_believe made_up';
my $post_id = $t->app->model('posts')->add({name => 'Bob', ssn => 1234, whatever => 'i want'});
diag $post_id;
like $post_id, qr(^\d+$), 'got posts id';
is $t->app->posts->get($post_id)->{whatever}, 'i want', 'got whatever';
is $t->app->posts->get(1)->{abc}, '123', 'got abc';
done_testing();
