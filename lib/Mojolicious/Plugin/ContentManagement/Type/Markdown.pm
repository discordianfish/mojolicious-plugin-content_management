package Mojolicious::Plugin::ContentManagement::Type::Markdown;

use warnings;
use strict;

use base 'Mojolicious::Plugin::ContentManagement::Type';

use Text::Markdown;

__PACKAGE__->attr( empty_element_suffix     => ' />' );
__PACKAGE__->attr( tab_width                => 4 );
__PACKAGE__->attr( markdown_in_html_blocks  => 0 );
__PACKAGE__->attr( trust_list_start_value   => 0 );

__PACKAGE__->attr( markdown => sub {
    my $self = shift;
    return Text::Markdown->new(
        empty_element_suffix    => $self->empty_element_suffix,
        tab_width               => $self->tab_width,
        markdown_in_html_blocks => $self->markdown_in_html_blocks,
        trust_list_start_value  => $self->trust_list_start_value,
    );
});

sub translate {
    my ($self, $input) = @_;
    return $self->markdown($input);
};

!! 42;
__END__

=head1 NAME

Mojolicious::Plugin::ManagedContent::Type::Plain - managed markdown content

=head1 SYNOPSIS

    my $html = $plain->translate($markdown);

=head1 DESCRIPTION

Store your managed content as Markdown!

=head1 ATTRIBUTES

=head2 empty_element_suffix
=head2 tab_width
=head2 markdown_in_html_blocks
=head2 trust_list_start_value

Markdown options. See L<Text::Markdown>

=head1 METHODS

=head2 translate

    my $html = $plain->translate($markdown);

Markdown translation.

=head1 SEE ALSO

L<Mojolicious::Plugin::ManagedContent>, L<Text::Markdown>
