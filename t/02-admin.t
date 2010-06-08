#!/usr/bin/env perl

use Mojolicious::Lite;
use FindBin '$Bin';
use Test::Mojo;
#use Test::More tests => 9;

#app->log->level('error');

app->renderer->root("$Bin/test-templates");

# Protect the admin interface
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
    type            => 'markdown', # TODO plain
    forbidden       => [ qr(/ba.*) ],
    admin_route     => $admin_route,
};

# Managed content goes here
get '/(*everything)' => ( content_management => 1 ) => 'page';

app->start;

__END__
