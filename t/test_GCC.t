package FakeTemplate {
	sub new {
		my $class = shift;
		my $self = { name => 'fakeTemplate' };
		return bless $self, $class;
	}
	sub name {
		my $self = shift;
		return $self->{name};
	}
}

use strict;
use warnings;
use Test::More;
use_ok( 't::fixtures::GenericCommandContext' );

my $gcc = new_ok( 'GenericCommandContext' );
my $tem = new_ok( 'FakeTemplate' );
my @false_funcs= (
	'leap_tall_buildings',
	'breathe_underwater',
	'beat_garry_kasparov'
);
foreach my $f ( @false_funcs ) {
	no strict 'refs';
	ok( $gcc->can( $f ) == 1, "GCC can $f" );
	ok( $gcc->$f( $tem ) eq $f, "Called/returned $f OK" );
}

done_testing();

