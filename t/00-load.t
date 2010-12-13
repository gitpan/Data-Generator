#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Data::Generator' ) || print "Bail out!
";
}

diag( "Testing Data::Generator $Data::Generator::VERSION, Perl $], $^X" );
