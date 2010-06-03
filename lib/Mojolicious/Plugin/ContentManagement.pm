package Mojolicious::Plugin::ContentManagement;

our $VERSION = '0.01';

use warnings;
use strict;

use base 'Mojolicious::Plugin';

use Carp;
use Mojo::ByteStream 'b';
use Mojo::Loader;

# I believe that qualifies as ill.
# At least from a technical standpoint.
sub register {
    my ($self, $app, $conf) = @_;

    # Default configuration
    $conf ||= {};
    $conf->{type}   ||= 'plain';
    $conf->{source} ||= 'filesystem';

    # Build type class name
    my $type_class = __PACKAGE__ . '::Type';
    $type_class .= '::' . b($conf->{type})->camelize;

    # Try to load type
    my $e = Mojo::Loader->load($type_class);
    croak   'Could\'t load content management type '
          . "'$conf->{type}' (class name: $type_class)"
        if $e;

    # Instantiate content type
    my $type_conf = $conf->{type_conf} || {};
    my $type = $type_class->new({
        %$type_conf,
        app => $app,
    });

    # Build source class name
    my $source_class = __PACKAGE__ . '::Source';
    $source_class .= '::' . b($conf->{source})->camelize;

    # Try to load source
    $e = Mojo::Loader->load($source_class);
    croak   'Couldn\'t load content management source '
          . "'$conf->{source}' (class name: $source_class)"
        if $e;

    # Instantiate content source
    my $source_conf = $conf->{source_conf} || {};
    my $source = $source_class->new({
        %$source_conf,
        app         => $app,
        type        => $type,
        forbidden   => $conf->{forbidden} || [],
    });

    # Closure page
    my $page;

    # Push page to stash if available
    $app->plugins->add_hook( before_dispatch => sub {
        my ($self, $c) = @_;
        my $path = $c->tx->req->url->path->to_string;
        undef $page;

        $c->stash( page => $page = $source->load($path) )
            if $source->exists($path);
    });

    # Routes condition to detect managed content
    $app->routes->add_condition( content_management => sub {
        my ($route, $tx, $captures, $arg) = @_;

        return $captures if $arg && $page;
        return;
    });

    # Helper generation for source methods
    for my $method (qw( exists list load )) {

        $app->renderer->add_helper( "content_$method" => sub {
            my ($self, $path) = @_;
            return $source->$method($path)
        });
    }
}

!! 42;
__END__

=head1 NAME

Mojolicious::Plugin::ContentManagement - Content management for Mojolicious

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

    do something crazy

=head1 DESCRIPTION

=head1 BUGS

Please use githubs issue tracker at
L<http://github.com/memowe/mojolicious-plugin-content_management>.

If you want to provide patches, feel free to fork and pull request me.

=head1 AUTHOR, COPYRIGHT AND LICENSE

Copyright (c) 2010 Mirko Westermeier, C<< <mail at memowe.de> >>

Released under the MIT license (see MIT-LICENSE) for details.
