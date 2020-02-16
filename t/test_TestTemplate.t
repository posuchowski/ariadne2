#!/usr/bin/env perl

BEGIN {
	push @INC, '.';
}

use strict;
use warnings;
use Test::More;
use Parser::Template::Sentence;

use_ok( 'Parser::Template::TestTemplate' );

# Instantiate
diag( "Testing instantiation" );
my $T = new_ok( 'Template', [ 'template' => 'eat $Noun' ] );
done_testing() unless defined $T;

# Simplest match
diag( "Testing simple token match: go north = go north" );
$T = new_ok( 'Template', [ 'template' => 'go north' ] );
my $yes = new_ok( 'Sentence' => [ raw => 'go north' ] );
my $no  = new_ok( 'Sentence' => [ raw => 'go west'  ] );

# Positive test
diag( "Testing correct match: " . $yes->raw );
ok( $T->matches( $yes ), "Yes, matches match" );
ok( ! $T->matches( $no ), "No, doesn\'t match wrong sentence" );

# Match and set simple variable $Noun
diag( "Testing variable setting" );
$T = new_ok( 'Template', [ 'template' => 'eat $Noun' ] );
my $test = Sentence->new( raw => 'eat turnip' );
my $wrong = Sentence->new( raw => 'eat dog' );
ok( $T->matches( $test ), "Template matches " . $test->raw );
is( $T->vars->{'Noun'}, 'turnip', "We eat \$Noun \'turnip\'" );

# Test or construction: word1|word2|...
diag( "Testing \'or\' construct: go|walk|stroll north" );
$T = new_ok( 'Template', [ 'template' => 'go|walk|stroll north' ] );
ok( $T->matches( Sentence->new( raw => 'walk north' ) ), "Template matches \'walk north\'" );

# Save 'or' construct to variable
$T = new_ok( 'Template', [ 'template' => '$Verb:go|walk|stroll north' ] );
my @verbs = ( 'go', 'walk', 'stroll' );
foreach my $verb ( @verbs ) {
	diag( "Testing verb \'$verb\'..." );
	ok(
		$T->matches( Sentence->new( raw => "$verb north" ) ),
		"Template matches \'$verb north\'"
	);
	is( $T->vars->{'Verb'}, $verb, "Verb used was: " . $T->vars->{'Verb'} );
}

# Test optional word
diag( "Testing optional word [a]" );
$T = new_ok( 'Template', [ 'template' => 'eat [a] burger' ] );
ok( $T->matches( Sentence->new( raw => 'eat burger' ) ), "Matches without optional \'a\'" );
ok( $T->matches( Sentence->new( raw => 'eat a burger' ) ), "Matches with optional \'a\'" );

# Test 'or' embedded in optional, saved to variable
diag( "Testing optional word [a|an|one]" );
$T = new_ok( 'Template', [ 'template' => 'eat $Q:[a|an|one] burger' ] );
my @quantifiers = ( '', 'a', 'an', 'one' );
foreach my $q ( @quantifiers ) {
	ok( $T->matches( Sentence->new( raw => "eat $q burger" ) ), "Matches: eat $q burger" );
	unless ( $q eq '' ) {
		is( $T->vars->{'Q'}, $q, "\tDid save quantifier: \'" . $T->vars->{'Q'} . "\'" );
	}
	else {
		is( $T->vars->{'Q'}, undef, "\tOK, empty string makes Q undef" );
		pass( "\t...And extra space in raw Sentence doesn't cause a problem" );
	}
}

# Complex test
diag( "Running a complex test" );
$T = new_ok( 'Template',
	[ 'template' => '$Adverb:[quickly|slowly|cautiously|carefully] open $Noun $Adverb:[quickly|slowly|cautiously|carefully]' ]
);
diag( "=> \'" . $T->template . "\'" );
my %successes = (
	'open door' => '',
	'open the door' => '',
	'quickly open the door' => 'quickly',
	'open the door slowly' => 'slowly',
	'carefully open the door' => 'carefully'
);
my @failures = (
	'open the door with gusto',
	'open the door nicely',
	'close door',
	"don\'t open the door",
	'wait around',
);
diag( "Testing successes for template" );
foreach my $s ( keys %successes ) {
	$T->reset();
	diag( "Test raw: $s" );
	ok( $T->matches( Sentence->new( raw => $s ) ), "\tOK, matches: $s" );
	if ( defined( $T->vars->{'Adverb'} ) ) {
		is( $T->vars->{'Adverb'}, $successes{"$s"}, "\tadverb matched: " . $T->vars->{'Adverb'} );
	}
	else {
		if ( $successes{$s} eq '' ) {
			pass( "\tadverb is undefined, good" );
		}
		else {
			fail( "\tadverb is undefined -- BUT expected = " . $successes{$s} );
		}
	}
}
diag( "Testing non-matches for above template" );
foreach my $s ( @failures ) {
	$T->reset();
	diag( "Test raw: $s" );
	ok( ! $T->matches( Sentence->new( raw => $s ) ), "Good, failed" );
}

done_testing();

