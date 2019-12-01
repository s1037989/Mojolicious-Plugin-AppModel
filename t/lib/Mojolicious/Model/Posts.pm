package Mojolicious::Model::Posts;

1;

__DATA__
@@ migrations
-- 2 up
insert into posts (doc) values ('{"abc":"123"}');

-- 2 down
delete from posts where doc->>'abc' = "123";
