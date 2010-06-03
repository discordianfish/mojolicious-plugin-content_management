#!/usr/bin/env perl

use Mojolicious::Lite;
use Test::Mojo;
use Test::More tests => 2;

# Content management configuration
plugin content_management => {
    source      => 'filesystem',
    source_conf => { directory => 'test-content' },
    type        => 'markdown',
    type_conf   => { empty_element_suffix => '>' },
    forbidden   => [ qr(/ba.*) ],
};

# Managed content goes to the template 'page'
get '/(*everything)' => ( content_management => 1 ) => 'page';

# Calm down, please!
app->log->level('error');

# Go for it!
my $t = Test::Mojo->new;

$t->get_ok('/foo.html')->content_is(<<'EOF');
<!doctype html><html>
    <head><title>MPC test!</title></head>
    <body><h1>This is /foo.html</h1>

<p>With <strong>Markdown</strong>, <br>
Yay!</p>
</body>
</html>
EOF

__DATA__

@@ page.html.ep
% layout 'default';
%== $page->html;

@@ not_found.html.ep
% layout 'default';
<h1>404 Not found</h1>

@@ layouts/default.html.ep
<!doctype html><html>
    <head><title>MPC test!</title></head>
    <body><%== content %></body>
</html>