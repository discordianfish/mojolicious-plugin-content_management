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
    return;
});

# Content management configuration
plugin content_management => {
    source          => 'filesystem',
    source_conf     => { directory => 'test-content' },
    type            => 'plain',
    forbidden       => [ qr(/ba.*) ],
    admin_route     => $admin_route,
};

# TODO weg samt template
get '/(*everything)' => ( content_management => 1 ) => 'page';

app->start;

__END__
