package Mojolicious::Plugin::ContentManagement::AdminController;

use warnings;
use strict;

use base 'Mojolicious::Controller';

sub list {
    # Nothing to do
    # the templates knows how to list the content pages.
}

sub edit {
    my $self = shift;
    my $path = $self->param('path');
    $self->stash(msg => "Hi, this is edit of $path!");
}

!! 42;
__DATA__
