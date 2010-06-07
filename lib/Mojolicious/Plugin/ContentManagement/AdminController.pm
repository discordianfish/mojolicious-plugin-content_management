package Mojolicious::Plugin::ContentManagement::AdminController;

use warnings;
use strict;

use base 'Mojolicious::Controller';

sub list {
    my $self = shift;
    $self->render(text => 'Hi, this is list!');
}

sub edit {
    my $self = shift;
    my $path = $self->param('path');
    #$self->render(text => "Hi, this is edit of $path!");
    $self->stash(msg => "Hi, this is edit of $path!");
}

!! 42;
__DATA__
