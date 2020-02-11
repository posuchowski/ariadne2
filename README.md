# ariadne2

========================================
Ariadne2 : Interactive Fiction Framework
========================================

My love for the text adventure goes back to Zork. However, I would rather write
a game than play a game. The primary goal of this project is to provide for as
natural and as rich user interaction as possible. It's easy to create a puzzle-
based game, but I think IF should be able to create the same kind of narrative
experience as reading a novel or watching a film.

Ariadne is named after the character in Inception, and is as old as the movie.
It's gone through several iterations. It keeps getting better and better, and
that's more important than it ever being finished. :)

Commits will generally allow running sample_game.pl, but this isn't guaranteed
since sometimes I just like to save my work.

====================
The Parser
====================

Parser::Template
	*::Parser
	*::Template
  *::Sentence

Not a natural language parser, Parser::Template works by matching raw sentences
passed into Parser::Template::Sentence to Parser::Template::Template's, which
allow variable saving, optional words, and a yada-yada slurp, like so:

	my $T = Template->new(
		template => 'open $Noun $Adverb:[quickly|fast|slowly|carefully]'
	);
	if (
		$T->matches( Sentence->new( raw => 'open the box carefully' ) )
	) {
		do_something();
	}


