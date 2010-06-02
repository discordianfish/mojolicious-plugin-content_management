package Mojolicious::Plugin::ContentManagement::Type;

use warnings;
use strict;

use base 'Mojo::Base';

use Carp;

sub translate { croak 'Method unimplemented by subclass!' }

!! 42;
__END__

=head1 NAME

Mojolicious::Plugin::ContentManagement::Type - abstract managed content type

=head1 SYNOPSIS

    package Mojolicious::Plugin::ContentManagement::Type::Foo;
    use base 'Mojolicious::Plugin::ContentManagement::Type';

    sub translate {
        my ($self, $input) = @_;
        return do_something_with($input);
    }

=head1 DESCRIPTION

A Mojolicious::Plugin::ContentManagement::Type is a thing that can translate
pages to html. This is an abstract base class.

=head1 METHODS

If you want to be a thing that can translate pages to html, you need to
implement the following methods:

=head2 translate

    my $html = $type->translate($input);

Output needs to be html.

=head1 SEE ALSO

L<Mojolicious::Plugin::ContentManagement>
