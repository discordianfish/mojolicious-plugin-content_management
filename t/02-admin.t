#!/usr/bin/env perl

use Mojolicious::Lite;
use FindBin '$Bin';
use Test::Mojo;
use Test::WWW::Mechanize::Mojo;
use Test::More tests => 15;

# Protect the admin interface
# (allow only admins who have a good user name / password combination) ;)
my $admin_route = app->routes->bridge('/admin')->to( cb => sub {
    my $self = shift;
    my $user = $self->param('user') || 'foo';
    my $pass = $self->param('pass') || 'bar';

    return 1 if $user eq $pass;
    
    $self->res->code(401);
    $self->res->body(<<'EOF');
<!doctype html><html>
<head><title>Authorization required</title></head>
<body><h1>401 Authorization required</h1></body>
EOF
});

# Content management configuration
plugin content_management => {
    source          => 'filesystem',
    source_conf     => { directory => 'test-content' },
    type            => 'plain',
    forbidden       => [ qr(/ba.*) ],
    admin_route     => $admin_route,
};

# Managed content goes here
get '/(*everything)' => ( content_management => 1 ) => 'page';

# Preparations
app->log->level('error');
app->renderer->root("$Bin/test-templates");
my $tester  = Test::Mojo->new(app => app);
my $t       = Test::WWW::Mechanize::Mojo->new(tester => $tester);

# Unauthorized
$tester->get_ok('/admin')->content_like(qr/Authorization required/);

# Authorized
$t->get_ok('/admin?user=foo&pass=foo');
$t->content_like(qr/Content Management Admin Interface/, 'got in');

# Get a page
my @pages   = $t->find_all_links(url_regex => qr|^/admin/edit|);
my $link    = shift @pages;
my $path    = $1 if $link->url =~ m|/admin/edit(.*)\?user=foo|;

# Find out how it looks
$t->get_ok($path);
my $content = $t->content;

# Go to the edit form and look if it matches the page
$t->get_ok($link->url);
my ($preview) = $t->content =~ m|<div id="preview">([^<]*)|;
is($content, $preview, 'edit form is right for the page');

# Preview
$t->submit_form(
    with_fields => {raw => 'foo'},
    button      => 'preview_button',
);
($preview) = $t->content =~ m|<div id="preview">([^<]*)|;
is($preview, 'foo', 'got the right preview');
$t->get_ok($path);
my $content2 = $t->content;
is($content2, $content, 'page is still in old state');

# Edit
$t->get_ok($link->url);
$t->submit_form(
    with_fields => {raw => 'foo'},
    button      => 'update_button',
);
($preview) = $t->content =~ m|<div id="preview">([^<]*)|;
is($preview, 'foo', 'got the right preview');
$t->get_ok($path);
my $content3 = $t->content;
is($content3, 'foo', 'page has changed');

# Undo
$t->get($link->url);
$t->submit_form(
    with_fields => {raw => $content},
    button      => 'update_button',
);
$t->get($path);
my $content4 = $t->content;
is($content4, $content, 'changes undone');

__END__
