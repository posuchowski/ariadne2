#!/usr/bin/env perl
use Test::More;
use TAP::Harness;

my @tests = (
	[ 't/test_GCC.t',	   't::fixtures::GenericCommandContext' ],
 	[ 't/test_Template.t', 'Parser::Template::Template' ],
 	[ 't/test_Sentence.t', 'Parser::Template::Sentence' ],
 	[ 't/test_Warning.t',  'Ariadne::Game::Warning' ],
);

# verbosity:
#   1 = verbose, print individual results
#   0 = normal
#  -1 = supress errors while tests running
#  -2 = summary only
#  -3 = silent
#
my %args = (
	'ignore_exit' => 1,
	'verbosity' => 1,
	'color' => 1,
	'trap' => 1,      # attempt print if SIGINT
	'lib' => [ '.' ]
);

my $harness = TAP::Harness->new( \%args );
my $aggregator = $harness->runtests( @tests );

