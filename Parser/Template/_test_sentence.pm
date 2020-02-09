#!/usr/bin/perl

use Sentence;

sub run_test {
    my $raw = shift;
    my $s = Sentence->new( raw => $raw );
    print "\n", "-" x 60, "\n";
    print "\t$raw\n";
    print "-" x 60, "\n";
    if( $s->mood ) { print "Mood: ", $s->mood, "\n"; }
    print "\t$_\n" foreach @{$s->tokens};
    print "-" x 60, "\n";
}

run_test( 'this is a test' );
run_test( 'this is a test!' );
run_test( 'say "something like this"' );

