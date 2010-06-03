#!/usr/bin/env perl

use Mojolicious::Lite;
use Test::Mojo;
use Test::More tests => 9;

# Content management configuration
plugin content_management => {
    source      => 'filesystem',
    source_conf => { directory => 'test-content' },
    type        => 'plain',
    forbidden   => [ qr(/ba.*) ],
};

# Managed content goes to the template 'page'
get '/(*everything)' => ( content_management => 1 ) => 'page';

# List content using helpers as a normal action
sub _stringify_page {
    my ($page, $indent) = @_;
    $indent ||= '';

    my $str = $indent . $page->path . "\n";
    $str .= _stringify_page($_, "$indent    ") for @{$page->children};

    return $str;
}

get '/list' => sub {
    my $self = shift;

    my $pages = $self->helper('content_list');
    $self->render( text => join '' => map _stringify_page($_) => @$pages );
};

# Calm down, please!
app->log->level('error');

# Go for it!
my $t = Test::Mojo->new;

# Pages
$t->get_ok('/foo.html')->content_like(qr|This is /foo.html|);
$t->get_ok('/foo/bar.html')->content_like(qr|This is /foo/bar.html|);

# Forbidden page
$t->get_ok('/baz.html')->status_is(404)->content_like(qr/404/);

# Pages list as normal Mojolicious action
$t->get_ok('/list.txt')->content_is(<<'EOF')
/foo.html
    /foo/bar.html
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
