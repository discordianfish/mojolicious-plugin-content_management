package Mojolicious::Plugin::ContentManagement::Source;

use warnings;
use strict;

use base 'Mojo::Base';

use Carp;

__PACKAGE__->attr([qw( app type forbidden )]);

sub exists  { croak 'Method unimplemented by subclass!' }

sub list    { croak 'Method unimplemented by subclass!' }

sub load    { croak 'Method unimplemented by subclass!' }

sub save    { croak 'Method unimplemented by subclass!' }

!! 42;
__END__

=head1 NAME

Mojolicious::Plugin::ContentManagement::Source - abstract source base class

=head1 DESCRIPTION

A Mojolicious::Plugin::ContentManagement::Source is a thing that can load
and write pages. This is an abstract base class.

=head1 IMPLEMENTATIONS SHIPPED WITH THIS DISTRIBUTION

=over 4

=item L<Mojolicious::Plugin::ContentManagement::Source::Filesystem>

Store content pages in a local directory

=item L<Mojolicious::Plugin::ContentManagement::Source::Dbi>

Store content pages in a L<DBI> compatible database

=back

=head1 ATTRIBUTES

=head2 app

    my $app = $source->app;
    $source = $source->app($app);

The Mojolicious app object

=head2 type

    my $type = $source->type;
    $source  = $source->type($type);

The management content type translator object (needed to build pages)

=head2 forbidden

    my @forbidden = @{ $source->forbidden };
    $source       = $source->forbidden([ 'foo', qr(foo/.*) ]);

An array ref of paths, that must not be managed. Can contain strings and
regular expressions

=head1 METHODS

If you want to be a thing that can load and save pages, you need to implement
the following methods:

=head2 exists

    my $truth = $source->exists('/foo/bar.html');

This method gets the path of a page and returns a true value iff such a page
exists.

=head2 list

    my $tree = $source->list;

This method returns a tree of all pages as an array ref of
L<Mojolicious::Plugin::ContentManagement::Page> objects.

=head2 load

    my $page = $source->load('/foo/bar.html');

This method loads a L<Mojolicious::Plugin::ContentManagement::Page> object.

=head2 save

    $source = $source->save($page);

This method saves a L<Mojolicious::Plugin::ContentManagement::Page> object.

=head1 SEE ALSO

L<Mojolicious::Plugin::ContentManagement>
