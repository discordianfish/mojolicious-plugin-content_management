#!/usr/bin/env perl

use Mojolicious::Lite;
use Test::Mojo;
use Test::More tests => 6;

# Content management configuration
plugin content_management => {
    source      => 'filesystem',
    source_conf => { directory => 'test-content' },
    type        => 'plain',
    forbidden   => [ qr(/ba.*) ],
};

# Managed content goes to the template 'page'
get '/(*everything)' => ( content_management => 1 ) => 'page';

# Other stuff
get '/baz' => sub { shift->render(text => 'baz from Mojolicious::Lite') };

# Calm down, please!
app->log->level('error');

# Go for it!
my $t = Test::Mojo->new;

# Pages
$t->get_ok('/foo.html')->content_like(qr|This is /foo.html|);
$t->get_ok('/foo/bar.html')->content_like(qr|This is /foo/bar.html|);

# Forbidden page and normal Mojolicious action
$t->get_ok('/baz.html')->content_is('baz from Mojolicious::Lite');

__DATA__

@@ page.html.ep
<!doctype html><html>
<head><title>MPCM test: <%= $page->title %></title></head>
<body><%== $page->html %></body>
</html>
