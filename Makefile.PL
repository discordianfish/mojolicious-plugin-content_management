#!/usr/bin/env perl

use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Mojolicious::Plugin::ContentManagement',
    AUTHOR              => 'Mirko Westermeier <mail@memowe.de>',
    VERSION_FROM        => 'lib/Mojolicious/Plugin/ContentManagement.pm',
    ABSTRACT_FROM       => 'lib/Mojolicious/Plugin/ContentManagement.pm',
    LICENSE             => 'mit',
    PL_FILES            => {},
    PREREQ_PM => {
        'Mojolicious'                   => 0.9999,
        'Text::Markdown'                => 1,
        'DBI'                           => 1.6,
        'Test::WWW::Mechanize::Mojo'    => '0.0.4',
        'Test::More'                    => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Mojolicious-Plugin-ContentManagement-*' },
);
