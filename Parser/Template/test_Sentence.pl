#!/usr/bin/env perl

BEGIN {
	push @INC, '.';
}

use strict;
use warnings;
use Test::More;

use_ok( 'Parser::Template::Sentence' );

my $test = 'eat shit and die';
my @tokens = split /\s/, $test;
my $S = new_ok(
	'Sentence',
	[ 'raw', $test ]
);
is_deeply( $S->tokens, \@tokens, "Correctly tokenized '$test'" );

my $test = 'eat the shit';
my @tokens = grep { $_ ne 'the' } split /\s/, $test;
print "\t(New test tokens: @tokens )\n";
my $S = Sentence->new( raw => $test );
is_deeply( $S->tokens, \@tokens, "Removed 'the' from 'eat the shit'" );

done_testing();
