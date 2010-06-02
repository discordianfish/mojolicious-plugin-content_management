package Mojolicious::Plugin::ContentManagement::Type::Plain;

use warnings;
use strict;

use base 'Mojolicious::Plugin::ContentManagement::Type';

sub translate {
    my ($self, $input) = @_;
    return $input;
};

!! 42;
__END__

=head1 NAME

Mojolicious::Plugin::ManagedContent::Type::Plain - plain managed content type

=head1 SYNOPSIS

    my $html = $plain->translate($input);

=head1 DESCRIPTION

This implements the identity function.

=head1 METHODS

=head2 translate

    my $html = $plain->translate($input);

The identity function.

=head1 SEE ALSO

L<Mojolicious::Plugin::ManagedContent>
