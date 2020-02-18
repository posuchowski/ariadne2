# ariadne2

I'm just getting started with (another) rewrite. This code just (hopefully)
passes unit tests. There is no playable game or anything like that, yet.

# Ariadne2 : Interactive Fiction Framework

My love for the text adventure goes back to Zork. However, I would rather write
a game than play a game. The primary goal of this project is to provide for as
natural and as rich user interaction as possible... eventually. It's easy to
create a puzzle-based game, but I think IF should be able to create the same
kind of narrative experience as reading a novel or watching a film.

Ariadne is named after the character in Inception, and is as old as the movie.
It's gone through several iterations. I am currently reworking the classes from
the original version into this one, while adding unit tests as I go.

Commits will generally allow running sample_game.pl, but this isn't guaranteed
since sometimes I just like to save my work.

## The Parser
```
Parser::Template
  *::Sentence
	*::Template
  *::Valid
	*::Command
	*::Parser
```

Not a natural-language parser, Parser::Template works by matching raw sentences
passed into Parser::Template::Sentence to Parser::Template::Template's, which
allow variable saving, optional words, and a yada-yada slurp, like so:
```
my $T = Template->new(
	template => 'open $Noun $Adverb:[quickly|fast|slowly|carefully]'
);
if (
	$T->matches( Sentence->new( raw => 'open the box carefully' ) )
) {
	do_something();
}
```

### Parser::Template::Sentence

Sentence conducts a pass to remove unwanted things, then tokenizes a sentence.
```
my $Sentence = Sentence => new(
	raw => STRING
	strip_words => ARRAYREF
);
```

### Parser::Template::Template

Template contains code that conducts a consumptive match of Sentence tokens against
a string template.
```
my $T = Template->new(
	template => 'open $Noun $Adverb:[quickly|fast|slowly|carefully]'
);
if (
	$T->matches( Sentence->new( raw => 'open the box carefully' ) )
) {
	do_something();
}
```

A template can have the following components:

literals: bare words are matched 
```
my $T = Template->new(
	template => 'wait'
);
```
variables: variables save the word used in the position the variable appears
```
my $T = Template->new(
	template => 'go $Direction'
);
```
The word in the position where `$Direction` appears will be saved to the
template's `vars` hash:
```
my $direction = $T->vars->{'Direction'};
```

### Parser::Template::Valid

No methods, just a set of lists of valid values for variables saved by the
Template match code. For example:

```
our @Adjective = { 'red', 'white', 'blue', 'metallic' };
```

Which is then tested against during a yada-yada slurp in a template like this:

```
take $Adjective:... $Noun
```

