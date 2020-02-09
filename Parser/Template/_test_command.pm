#!/usr/bin/perl

use Sentence;
use Command;
use Data::Printer;

sub run_test {
    my( $tmp, $sen ) = @_;
    my $c;
    unless( ref($tmp) ) {
        $c = Command->new( verb => $tmp, templates => [ $tmp ], context => 'None', code => '1;' );
    }
    else {
        $c = Command->new( verb => $tmp->[0], templates => $tmp, context => 'None', code => '1;' );
    }
    my $s = Sentence->new( raw => $sen );
    my $r = $c->matches( $s );
    print $c->{templates}->[0], ' =~ ', $s->raw, ": ";
    if( $r ) {
        print "\tYES\n"; 
        foreach my $k ( keys( %{$c->{vars}} ) ) {
            print "\t$k = ", $c->{vars}->{$k}, "\n";
        }
    }
    else {
        print "\tNO\n";
    }
} 

#
# Test Literal Matching: word1 word2 word3...
#
print "\nTesting Literal Matching\n", "-" x 40, "\n";
run_test( 'eat shit', 'eat shit' );
run_test( 'eat shit', 'eat'      );
run_test( 'eat shit', 'do something nice for a change' );
print "-" x 40, "\n\n";

#
# Test 'Or' Matching: word1|word2|word3
#
print "Testing Or Matching\n", "-" x 40, "\n";
run_test( 'go|walk|saunter north', 'walk north' );
run_test( 'go|walk|saunter north', 'go north' );
run_test( 'go|walk|saunter north', 'saunter south' );
run_test( 'go|walk|saunter north', 'go' );
print "-" x 40, "\n\n";

#
# Test [Optional] Matching: [word]
#
print "Testing [Optional] Matching\n", "-" x 40, "\n";
run_test( 'walk [to] north', 'walk north' );
run_test( 'walk [to] north', 'walk to north' );
run_test( 'walk [to] north', 'walk towards north' );
run_test( 'walk [to] [the] north', 'walk north' );
run_test( 'walk [to] [the] north', 'walk to north' );
run_test( 'walk [to the|towards] north', 'walk towards north' );
run_test( 'walk [to|towards] [the] north', 'walk towards the north' );
run_test( 'walk [to|towards] [the] north', 'walk towards north' );
run_test( 'walk [to|towards] [the] north', 'walk to the north' );
run_test( 'walk [to|towards] [the] north', 'walk to towards the north' );
print "-" x 40, "\n\n";

#
# Test variable storage: $MyVar : { MyVar => 'value' }
#
print "Testing Variable Storage\n", "-" x 40, "\n";
run_test( 'walk [to|towards] [the] $Direction', 'saunter south' );
run_test( 'walk [to|towards] [the] $Direction', 'walk to the north' );
run_test( 'say $Text', 'say "this is the end, my only friend, the end"' );

#
# Misc
#
print "Testing More Complex Stuff\n", "-" x 40, "\n";
run_test( 'take $DO to $IO', 'take the cake to Peter' );
run_test(
    [ 'go [to] $Direction',
      'walk|run [to] $Direction',
      'saunter [to] $Direction' ],
    'run north'
);

#
# Test $Variable:[word1|word2] type matches
#
print "Testing Variables with Specs\n", '-' x 40, "\n";
run_test( 'go $Direction:north|south', 'go west' );
run_test( 'go $Direction:north|south', 'go north' );


