#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use_ok( 'Parser::Template::Sentence' );

{
	diag( "Testing Sentence tokenization" );
	my $test = 'eat shit and die';
	my @tokens = split /\s/, $test;
	my $S = new_ok(
		'Sentence',
		[ 'raw', $test ]
	);
	is_deeply( $S->tokens, \@tokens, "Correctly tokenized '$test'" );
}

{
	diag( "Testing Sentence strip words" );
	my $test = 'put the cat into the basket';
	my @tokens = grep { $_ ne 'the' } split /\s/, $test;
	print "\t(New test tokens: @tokens )\n";
	my $S = Sentence->new( raw => $test );
	is_deeply( $S->tokens, \@tokens, "Removed 'the' from 'put the cat into the basket'" );
}

{
	diag( "Testing Sentence strip punctuation" );
	my $test = 'say, "Well then, you had better get going."';
	my $S = Sentence->new( raw => $test );
	foreach my $s ( '\"', '\,', '\.' ) {
		$test =~ s/$s//g;
	}
	my @tokens = split /\s/, $test;
	diag( "Stripped is now " . $S->stripped );
	ok( $S->stripped eq 'say Well then you had better get going', "OK, puncs removed!" );
	is_deeply( $S->tokens, \@tokens, "Tokens are OK" );
}

{
	diag( "Testing Sentence saving ! in mood var" );
	my $test = 'I am serious distraught about this!';
	my $S = Sentence->new( raw => $test );
	ok( $S->mood eq '!', "Saved exclamation point" );
	$test =~ s/!$//; my @tokens = split /\s/, $test;
	is_deeply( $S->tokens, \@tokens, "And tokens are still OK" );
}

{
	diag( "Testing Sentence saving ! in mood var" );
	my $test = 'Where am I?';
	my $S = Sentence->new( raw => $test );
	ok( $S->mood eq '?', "Saved question mark" );
	$test =~ s/\?$//; my @tokens = split /\s/, $test;
	is_deeply( $S->tokens, \@tokens, "And tokens are still OK" );
}

done_testing();
