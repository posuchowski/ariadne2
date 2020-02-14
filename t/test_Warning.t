use strict;
use warnings;

use Test::More;

use_ok( 'Game::Warning' );
my $W = new_ok( 'Warning', [ 'Test', 'Warning' ] );

done_testing();
