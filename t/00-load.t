#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Mojolicious::Plugin::ContentManagement' );
}

diag( "Testing Mojolicious::Plugin::ContentManagement $Mojolicious::Plugin::ContentManagement::VERSION, Perl $], $^X" );
