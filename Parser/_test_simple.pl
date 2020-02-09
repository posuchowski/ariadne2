#!/usr/bin/perl

use Test::More tests => 8;
use Data::Dumper;

BEGIN {
    use_ok( 'Simple::Command'  );
    use_ok( 'Simple::Commands' );
    use_ok( 'Simple::Sentence' );
}

#
# Test class Simple
#
my $r = "take the lettuce with tongs";
my @toks = qw| take lettuce with tongs |;
my $s = Sentence->new(
    raw => $r,
);

is( $s->raw, $r, "Sentence set raw" );
is_deeply ( $s->tokens, \@toks, "Test sentence tokenized OK" );

#
# Test class Command
#
my $c = Command->new(
    word => 'edit',
    direct_objects => [ 'this' ],
    indirect_objects => [ 'with', 'using' ],
);
my $s = Sentence->new(
    raw => 'edit this code using vim',
);
my @expected = qw| edit this using |;
my @matched = $c->matches( $s );
print Dumper( @matched );

is_deeply( \@matched, \@expected, "Matched 'edit' 'using' as expected." );
is( $c->direct_o,   'this',  'Stored direct_o   = this' );
is( $c->indirect_o, 'using', 'Stored indirect_o = using' );

