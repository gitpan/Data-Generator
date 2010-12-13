use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Data::Generator',
    AUTHOR              => q{Eriam Schaffter <eriam@cpan.org>},
    VERSION_FROM        => 'lib/Data/Generator.pm',
    ABSTRACT_FROM       => 'lib/Data/Generator.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Data-Generator-*' },
);
