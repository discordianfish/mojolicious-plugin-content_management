#!/usr/bin/env perl

use Test::More tests => 7;
use Mojolicious::Plugin::ContentManagement::Source::DBI;
use Mojolicious::Plugin::ContentManagement::Type::Plain;
use DBI;
use FindBin '$Bin';

# Preparations
my $dsn     = "dbi:SQLite:dbname=$Bin/test-db/db.sqlite";
my $dbh     = DBI->connect($dsn, '', '') or die $DBI::errstr;
my $type    = Mojolicious::Plugin::ContentManagement::Type::Plain->new;
my $source  = Mojolicious::Plugin::ContentManagement::Source::DBI->new({
    type        => $type,
    forbidden   => [ qr(/ba.*) ],
    dbh         => $dbh,
    prefix      => 'foo',
});

# May the tests begin!

# exists
ok($source->exists('/foo/bar.html'), "/foo/bar.html exists");
ok(!$source->exists('/baz.html'), "forbidden page doesn't exist");

# load
my $foo = {
    path        => '/foo.html',
    title       => 'This is /foo.html',
    html        => 'Yay',
    raw         => 'Yay',
    children    => [{
        path        => '/foo/bar.html',
        title       => 'This is /foo/bar.html',
        html        => 'Yay',
        raw         => 'Yay',
        children    => [],
        title_editable => 1,
        data        => { parent => '/foo.html', sort => '02' },
    }],
    title_editable => 1,
    data        => { parent => undef, sort => '03' },
};
my $foo_page = $source->load('/foo.html');
is_deeply($foo_page, $foo, "got the right page object");

# list
my $root = {
    path        => '',
    children    => [$foo],
};
is_deeply($source->list, $root, "got the right page list");

# save
my $foo_new = $foo_page->clone;
$foo_new->title('quux')->raw('quuux');
$source->save($foo_new);
my $foo_new_updated = $source->load($foo_new->path);
is($foo_new_updated->title, 'quux', "title updated");
is($foo_new_updated->raw, 'quuux', "raw updated");

# undo
$source->save($foo_page);
is_deeply($foo_page, $foo, "all changes undone");

__END__
