package Mojolicious::Plugin::ContentManagement::Source::Dbi;

use warnings;
use strict;

use base 'Mojolicious::Plugin::ContentManagement::Source';

use Mojolicious::Plugin::ContentManagement::Page;
use DBI;

__PACKAGE__->attr([qw( dbh prefix )] => '');

__PACKAGE__->attr( table => sub {
    my $self = shift;
    return $self->prefix . '_pages' if $self->prefix;
    return 'pages';
});

# Build SQL statement handles
__PACKAGE__->attr( sth => sub {
    my $self    = shift;
    my $table   = $self->table;

    my %sql = (
        one         => "SELECT * FROM $table WHERE path = ?",
        children    => "SELECT * FROM $table WHERE parent = ? ORDER BY sort",
        all         => "SELECT * FROM $table ORDER BY sort",
        save        => "UPDATE $table SET title = ?, raw = ? WHERE path = ?",
    );

    $sql{$_} = $self->dbh->prepare($sql{$_}) for keys %sql;
    
    return \%sql;
});

sub _forbidden_check {
    my ($self, $path) = @_;

    # Match! Forbidden!
    return 1 if grep { $path =~ /^$_$/ } @{$self->forbidden};

    # Allow
    return;
}

sub _build_page_from_hash { # no children handling
    my ($self, $h) = @_;

    Mojolicious::Plugin::ContentManagement::Page->new({
        path            => $h->{path},
        title           => $h->{title},
        html            => $self->type->translate($h->{raw}),
        raw             => $h->{raw},
        title_editable  => 1,
        children        => [],
        data            => {
            parent  => $h->{parent},
            sort    => $h->{sort},
        },
    });
}

sub list {
    my $self = shift;

    # Fetch all pages
    my $sth = $self->sth->{all};
    $sth->execute;
    my $pages = $sth->fetchall_arrayref({});

    # Drop forbidden pages
    $pages = [ grep { ! $self->_forbidden_check($_->{path}) } @$pages ];

    # Build pages
    $pages = [ map { $self->_build_page_from_hash($_) } @$pages ];

    # Root
    my $root = Mojolicious::Plugin::ContentManagement::Page->new({
        children => $pages,
    });

    # Come together, families!
    my @root_children;
    foreach my $page (@$pages) {

        # Has a parent!
        if (my $parent = $root->find($page->data->{parent})) {
            push @{ $parent->children }, $page;
        }
        # Childrens
        else {
            push @root_children, $page;
        }
    }

    return \@root_children;
}

sub load {
    my ($self, $path) = @_;
    return if $self->_forbidden_check($path);

    # Fetch the page
    my $sth = $self->sth->{one};
    $sth->execute($path);
    my $row = $sth->fetchrow_hashref;

    return unless $row;

    # Build the page
    my $page = $self->_build_page_from_hash($row);

    # Fetch the children
    $sth = $self->sth->{children};
    $sth->execute($path);
    my $children = $sth->fetchall_arrayref({});

    # Build children pages
    $children = [ map { $self->_build_page_from_hash($_) } @$children ];

    return $page->children($children);
}

sub exists {
    my ($self, $path) = @_;
    return if $self->_forbidden_check($path);

    # Fetch the page
    my $sth = $self->sth->{one};
    $sth->execute($path);
    my $row = $sth->fetchrow_hashref;

    return 1 if $row;
    return;
}

sub save {
    my ($self, $new_page) = @_;

    # Shortcut
    return unless $self->exists($new_page->path);

    # Save
    my $sth = $self->sth->{save};
    $sth->execute($new_page->title, $new_page->raw, $new_page->path);

    return $self;
}

!! 42;
__END__

=head1 NAME

Mojolicious::Plugin::ContentManagement::Source::DBI - content from database

=head1 SYNOPSIS

    my $dsn = DBI->connect(...);

    # Mojolicious
    $self->plugin( content_management => {
        source      => 'dbi',
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

=head1 CONFIGURATION

With the C<source_conf> hash ref you can pass the C<directory> under which the
content files will live. Default: C<'content'>

=head1 METHODS

This class implements the abstract methods of its base class 
L<Mojolicious::Plugin::ContentManagement::Source> and the following new ones:

=head2 build_tree

    my $filesystem = $filesystem->build_tree;

You can call this method to refresh the page tree from the filesystem.

=head1 SEE ALSO

L<Mojolicious::Plugin::ContentManagement>,
L<Mojolicious::Plugin::ContentManagement::Source> 
