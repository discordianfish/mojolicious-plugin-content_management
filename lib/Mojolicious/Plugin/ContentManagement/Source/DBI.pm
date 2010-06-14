package Mojolicious::Plugin::ContentManagement::Source::DBI;

use warnings;
use strict;

use base 'Mojolicious::Plugin::ContentManagement::Source';

use Mojolicious::Plugin::ContentManagement::Page;
use DBI;

__PACKAGE__->attr([qw( dbh prefix )] => '');

__PACKAGE__->attr( table => sub {
    my $self = shift;
    return $self->prefix . '_pages';
    return 'pages';
});

__PACKAGE__->attr( one_sth => sub {
    my $self    = shift;
    my $table   = $self->table;
    $self->dbh->prepare("SELECT * FROM $table WHERE path = ?");
});

__PACKAGE__->attr( all_sth => sub {
    my $self    = shift;
    my $table   = $self->table;
    $self->dbh->prepare("SELECT * FROM $table ORDER BY PATH ASC");
});

sub _forbidden_check {
    my ($self, $path) = @_;

    # Match! Forbidden!
    return 1 if grep { $path =~ /^$_$/ } @{$self->forbidden};

    # Allow
    return;
}

sub list { die 'unimplemented!' }

sub load {
    my ($self, $path) = @_;
    return if $self->_forbidden_check($path);

    my $sth = $self->one_sth->execute($path);
    my $row = $sth->fetchrow_hashref;

    return unless $row;

    return Mojolicious::Plugin::ContentManagement::Page->new({
        path            => $path,
        title           => $row->{title},
        html            => $self->type->translate($row->{raw}),
        raw             => $row->{raw},
        title_editable  => 1,
        children        => [], # hm!
    });
}

sub exists {
    my ($self, $path) = @_;
    return if $self->_forbidden_check($path);

    my $sth = $self->one_sth->execute($path);
    my $row = $sth->fetchrow_hashref;

    return 1 if $row;
    return;
}

sub save {
    my ($self, $new_page) = @_;
    return if $self->_forbidden_check($new_page->path);

    die 'unimplemented!';
    return $self;
}

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
