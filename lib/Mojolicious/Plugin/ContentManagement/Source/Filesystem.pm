package Mojolicious::Plugin::ContentManagement::Source::Filesystem;

use warnings;
use strict;

use base 'Mojolicious::Plugin::ContentManagement::Source';

use File::Spec;
use Mojo::Asset::File;
use Mojolicious::Plugin::ContentManagement::Page;
use Carp;

__PACKAGE__->attr( directory    => 'content' );
__PACKAGE__->attr( tree         => sub { shift->build_tree->tree });

sub _children {
    my ($self, $path) = @_;

    opendir my $dirh, $path or return;
    my @children = ();

    while (my $entry = readdir $dirh) { 
        next if $entry =~ /^\./;
        my $name = File::Spec->catdir($path, $entry);

        # Calculate path
        my $cdir    = $self->app->home->rel_dir($self->directory);
        (my $rname  = $name) =~ s/^$cdir// or croak 'Whoops!';
        my @parts   = File::Spec->splitdir($rname);
        s/^(\d+-)?// for @parts;
        my $ppath   = join '/' => @parts;

        # Check for forbidden paths
        next if grep { $ppath =~ /^$_$/ } @{$self->forbidden};

        # Page found
        if (-f $name && -r $name) {
            
            # Retrieve content
            my $content = Mojo::Asset::File->new(path => $name)->slurp;
            my $html    = $self->type->translate($content);
            my $title   = ($html =~ m|<h1>(.*?)</h1>|) ? $1 : $ppath;

            # Build page
            push @children, Mojolicious::Plugin::ContentManagement::Page->new({
                path    => $ppath,
                title   => $title,
                html    => $html,
                data    => { filename => $name },
            });
        }

        # Directory found
        elsif (-d $name && -x $name) {

            # Build empty page with children
            push @children, Mojolicious::Plugin::ContentManagement::Page->new({
                path        => $ppath,
                children    => $self->_children($name),
                data        => { filename => $name, type => 'dir_only' },
            });
        }

    }

    # Merge pages and directories
    my %last = ();
    for my $child (@children) {

        # Kill page extension
        (my $ppath = $child->path) =~ s|\.[^/]+$||;

        if (my $last = $last{$ppath}) {

            # Merge
            my $page = $last->children ? $child : $last;
            my $dir  = $last->children ? $last : $child;
            $page->children($dir->children);
            $last{$ppath} = $page;
        }
        else {
            $last{$ppath} = $child;
        }
    }

    # Sort the children (Schwartzian transform)
    my @sorted =    map { $_->[0] }
                    sort { $a->[1] cmp $b->[1] }
                    map {[ $_ => $_->data->{filename} ]}
                    values %last;

    return \@sorted;
}

sub build_tree {
    my $self = shift;

    my $dir = $self->app->home->rel_dir($self->directory);

    # Build the root "page"
    $self->tree(Mojolicious::Plugin::ContentManagement::Page->new({
        children => $self->_children($dir),
    }));

    return $self;
}

sub list { shift->tree->children }

sub load { shift->tree->find(shift) }

sub exists { shift->load(shift) }

!! 42;
__END__

=head1 NAME

Mojolicious::Plugin::ContentManagement::Source::Filesystem - content from files

=head1 SYNOPSIS

    # Mojolicious
    $self->plugin( content_management => {
        source      => 'filesystem',
        source_conf => { directory => 'content' },
        ...
    });

    # Mojolicious::Lite
    plugin content_management => {
        source      => 'filesystem',
        source_conf => { directory => 'content' },
        ...
    };

=head1 DESCRIPTION

Now you can use the filesystem for content management. With the settings above
you can have a directory structure like this:

    project_dir/
        content/
            01-foo.html
            01-foo/
                bar.html
            02-baz.html

which will give you three pages,

    /foo.html
    /foo/bar.html
    /baz.html

You can place a number and a dash in front of the files or directories to
define the ordering.

=head1 METHODS

This class implements the following methods according to its abstract base class
L<Mojolicious::Plugin::ContentManagement::Source> 

There's one more method:

=head2 build_tree

    my $filesystem = $filesystem->build_tree;

You can call this method to refresh the page tree from the filesystem.

=head1 SEE ALSO

L<Mojolicious::Plugin::ContentManagement>,
L<Mojolicious::Plugin::ContentManagement::Source> 
