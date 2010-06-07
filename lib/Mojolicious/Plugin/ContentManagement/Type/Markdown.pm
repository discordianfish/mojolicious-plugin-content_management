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
    return $self->markdown->markdown($input);
}

!! 42;
__END__

=head1 NAME

Mojolicious::Plugin::ManagedContent::Type::Markdown - managed markdown content

=head1 SYNOPSIS

    my $html = $markdown->translate($input);

=head1 DESCRIPTION

Store your managed content as Markdown!

=head1 CONFIGURATION

You can pass these options as C<type_conf>:

=over 4

=item empty_element_suffix

=item tab_width

=item markdown_in_html_blocks

=item trust_list_start_value

=back

See L<Text::Markdown> for informations about these options.

=head1 ATTRIBUTES

=head2 empty_element_suffix

    my $ees   = $markdown->empty_element_suffix;
    $markdown = $markdown->empty_element_suffix(' />');

=head2 tab_width

    my $tw    = $markdown->tab_width;
    $markdown = $markdown->tab_width(4);

=head2 markdown_in_html_blocks

    my $mihb  = $markdown->markdown_in_html_blocks
    $markdown = $markdown->markdown_in_html_blocks(0);

=head2 trust_list_start_value

    my $tlsv  = $markdown->trust_list_start_value
    $markdown = $markdown->trust_list_start_value(0);

Markdown options. See L<Text::Markdown>

=head1 METHODS

=head2 translate

    my $html = $plain->translate($markdown);

Markdown translation.

=head1 SEE ALSO

L<Mojolicious::Plugin::ManagedContent>,
L<Mojolicious::Plugin::ManagedContent::Type>, L<Text::Markdown>
