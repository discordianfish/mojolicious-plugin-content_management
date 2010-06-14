package Mojolicious::Plugin::ContentManagement;

our $VERSION = '0.01';

use warnings;
use strict;

use base 'Mojolicious::Plugin';

use Carp;
use Mojo::ByteStream 'b';
use Mojo::Loader;

__PACKAGE__->attr('app');
__PACKAGE__->attr( conf     => sub { {} } );
__PACKAGE__->attr( source   => sub { shift->_load->source } );
__PACKAGE__->attr( type     => sub { shift->_load->type } );

# I believe that qualifies as ill.
# At least from a technical standpoint.
sub register {
    my ($self, $app, $conf) = @_;

    $self->app($app);
    $self->conf($conf) if $conf;

    # Closure data
    my $page;

    # Push page to stash if available
    $app->plugins->add_hook( before_dispatch => sub {
        my ($s, $c) = @_;
        my $path = $c->tx->req->url->path->to_string;
        undef $page;

        $c->stash( content_page => $page = $self->source->load($path) )
            if $self->source->exists($path);
    });

    # Routes condition to detect managed content
    $app->routes->add_condition( content_management => sub {
        my ($route, $tx, $captures, $arg) = @_;

        return $captures if $arg && $page;
        return;
    });

    # Helper generation for source methods
    for my $method (qw( exists list load save )) {

        $app->renderer->add_helper( "content_$method" => sub {
            my $c = shift;
            return $self->source->$method(@_);
        });
    }

    # Helper for type translation
    $app->renderer->add_helper( content_translate => sub {
        my $c = shift;
        return $self->type->translate(@_);
    });

    $app->log->info('Content management loaded');

    # No admin functionality needed shortcut
    return unless $conf->{admin_route};

    # Admin routes
    my %defaults = (
        namespace   => 'Mojolicious::Plugin::ContentManagement',
        controller  => 'admin_controller',
        cb          => undef, # overwrite callback bridges
    );
    my $r = $conf->{admin_route};
    $r->route('/')->to(%defaults, action => 'list')
        ->name('content_management_admin_list');
    $r->route('/edit(*path)', path => qr(/.*))
        ->to(%defaults, action => 'edit')
        ->name('content_management_admin_edit');

    # TODO DBI-Source
    # TODO zwei Stufen von Adminsachen
    # TODO 1. bearbeiten
    # TODO 2. löschen und neuerstellen
    # TODO      dafür: Regex-Regeln was erlaubt ist! Wow, das ist toll!
}

sub _load {
    my $self = shift;

    # Default configuration
    my $conf = $self->conf;
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
    $self->type($type_class->new({
        %$type_conf,
        app => $self->app,
    }));

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
    $self->source($source_class->new({
        %$source_conf,
        app         => $self->app,
        type        => $self->type,
        forbidden   => $conf->{forbidden} || [],
    }));
}

!! 42;
__END__

=head1 NAME

Mojolicious::Plugin::ContentManagement - Content management for Mojolicious

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

    use Mojolicious::Lite;

    plugin content_management => {
        source      => 'filesystem',
        source_conf => { directory => 'content' },
        type        => 'markdown',
        type_conf   => { empty_element_suffix => '>' },
        forbidden   => [ '/foo.html', qr|/bar/\d{4}/baz.html| ],
    };

    get '/(*everything)' => ( content_management => 1 ) => 'page';

    #...

    __DATA__

    @@ page.html.ep
    % layout 'default';
    %== $content_page->html;

=head1 DESCRIPTION

This is a simple but flexible and extendable content management system that
seamlessly integrates into your Mojolicious or Mojolicious::Lite app. You can
use your own controllers around content generation and create your own bridge
or waypoint routes for the optional admin interface.

=head2 USAGE

First, Mojolicious::Plugin::ContentManagement (called MPCM from now on) comes
as a Mojolicious controller that can be used with the standard plugin code:

    # Mojolicious
    sub startup {
        my $self = shift;
        $self->plugin( content_management => $conf );
        ...
    }

    # Mojolicious::Lite
    plugin content_management => $conf;

The C<$conf> scalar needs to be a hashref with the following keys:

=over 4

=item source

The source class used to store and generate content pages.
See L<Mojolicious::Plugin::ContentManagement::Source> for implementations.

=item source_conf

A configuration hashref that is passed to your C<source> class. See the
documentation of your source class for more details.

=item type

The type class. This is a translator for your content pages.
See L<Mojolicious::Plugin::ContentManagement::Type> for implementations.

=item type_conf

A configuration hashref that is passed to your C<type> class. See the
documentation of your source class for more details.

=item forbidden

An arrayref with paths and path regexes which must not be managed by MPCM
(because you need them for your own routes and actions).

=back

=head1 BUGS

Please use githubs issue tracker at
L<http://github.com/memowe/mojolicious-plugin-content_management>.

If you want to provide patches, feel free to fork and pull request me.

=head1 AUTHOR, COPYRIGHT AND LICENSE

Copyright (c) 2010 Mirko Westermeier, C<< <mail at memowe.de> >>

Released under the MIT license (see MIT-LICENSE) for details.
