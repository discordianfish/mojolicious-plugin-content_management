package Mojolicious::Plugin::ContentManagement::Page;

use warnings;
use strict;

use base 'Mojo::Base';

use List::Util 'first';

__PACKAGE__->attr([qw( path title html children )]);
__PACKAGE__->attr( data => sub { {} } );

sub find {
    my ($self, $path) = @_;

    # Shortcuts
    return $self if $path eq $self->path;
    return unless $self->children;

    # Ask the children
    for my $child (@{$self->children}) {

        my $found = $child->find($path);
        return $found if $found;
    }

    # Not found
    return;
}

!! 42;
__END__

=head1 NAME

Mojolicious::Plugin::ContentManagement::Page - a managed content page

=head1 ATTRIBUTES

=head2 path

    my $path = $page->path;
    $page    = $page->path('/foo/bar.html');

The page identifying request url path

=head2 title

    my $title = $page->title;
    $page     = $page->title('My first pony');

The title of the page, probably used for navigations

=head2 html

    my $html = $page->html;
    $page    = $page->html('<h1>My first pony</h1><p>...');

The content of the page

=head2 children

    my $children = $page->children;
    $page        = $page->children([ $page2, $page3 ]);

Tree organisation of pages, probably used for navigations

=head2 data

    my %data = %{ $page->data };
    $page    = $page->data({ foo => bar });

Source specific data. Please do not use it unless you're developing a source.

=head1 METHODS

=head2 find

    my $p   = $page->find('/foo/bar.html');

Searches for a path in this page or the children and returns the matching page

=head1 SEE ALSO

L<Mojolicious::Plugin::ContentManagement>
