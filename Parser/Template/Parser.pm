package Parser v0.2.1;
use v5.18;
use List::MoreUtils 'any';
use Parser::Template::Sentence;
use Parser::Template::Command;
use Parser::Template::Valid;
use Parser::Template::ErrMsg;
use Parser::Template::Valid;
use Data::Printer;

sub new {
    my $class = shift;
    my %args  = @_;
    my $self = {
        game => $args{'game'},
        commands => $args{'commands'},
        prev_vars => {},
        match => {},
    };
    unless( defined $self->{game} ) {
        die( "Parser needs a game hook passed to new in arg \'game\'.\nHint: Parser->new( game => \$ariadne )\n" );
    }
    bless( $self, $class );
    $self->build_vocab;
    return $self;
}

sub substitute_nouns {
    my( $self, $s ) = @_;
    my @candidates;
    my $o;

    # harvest candidates matching the full sentence, with the matching word(s)
    while( $o = $self->{game}->iter_objects ) {
        my @matching = $o->match( $s );
        # say ref($o) . " matched with: @matching";
        if( @matching ) {
            push @candidates, [ $o, \@matching ];
        }
    }
    unless( @candidates ) {
        # say "Parser: returning from substitute_nouns with no candidates";
        return;
    }

    # sort the array in acending order by number of matching words (i.e. specificity)
    # say "Parser: before sort:"; p( @candidates );
 
    if( @candidates > 1 ) {
        @candidates = sort { @{$a->[1]} <=> @{$b->[1]} } @candidates;
    }

    # say "\nParser: after sort: @candidates";

    # iterate through them, checking if they still match and subbing if they do
    while( @candidates ) {
        my $c = pop @candidates;
        my @m = $c->[0]->match( $s );
        if( @m == @{$c->[1]} ) {                # i.e. match is still just as good
            my $n = pop @m;
            push @{ $self->{match}->{nouns} }, $n;
            $s->replace( $n, $c->[0]->{uuid} );      # replace the noun with uuid
            $s->remove( @m ) if @m;                  # eliminate the rest
        }
        # else { say "Parser: Candidate is discarded: @m"; }
    }
}

sub test_special_vars {
    my( $self, $cmd ) = @_;
    my $err = 0;
    my $msg = "";

    no strict 'refs';
    foreach my $var( keys %{$cmd->{vars}} ) {
        my $test = "Valid::$var";
        unless( defined $$test ) {
            next;
        }
        unless( any { $_ eq $cmd->{vars}->{$var} } @{$$test} ) {
            $err = 1;
            $msg = "The word '". $cmd->{vars}->{$var} . "' is not a valid " . lc $var . ".";
            last;
        }
    }
    return ( $err, $msg );
}

sub substitute_pronouns {
    my( $self, $match ) = @_;
    foreach my $v( keys %{$match->{vars}} ) {
        if( any { $_ eq $match->{vars}->{$v} } @{$Valid::Pronouns} ) {
            if( exists $self->{prev_vars}->{$v} ) {
                my $o = $self->{game}->obj_by_id( $self->{prev_vars}->{$v} );
                next unless defined $o;
                if( any { $_ eq $match->{vars}->{$v} } @{$o->{pronouns}} ) {
                    $match->{vars}->{$v} = $self->{prev_vars}->{$v};
                    push @{ $self->{match}->{nouns} }, $self->{prev_vars}->{$v};
                }
            }
            else {
                my @keys = sort keys %{$self->{prev_vars}};
                $match->{vars}->{$v} = $self->{prev_vars}->{$keys[0]};
            }
        }
    }
}

sub parse {
    my( $self, $raw, $doer ) = @_;
    my $match;
    $self->{match} = {
        nouns => [],
    };
    my $s = Sentence->new( raw => lc($raw) );

    $self->substitute_nouns( $s );

    foreach my $c ( @{$self->{commands}} ) {
        my $m = $c->matches( $s );
        if( $m ) {
            my ( $err, $msg ) = $self->test_special_vars( $c );
            unless( $err ) {
                $match = $c->clone;  # return a deep copy
                last;
            }
        }
    }
    unless( $match ) {
        return Parser::Template::ErrMsg->new(
            err => 1,
            msg => "No command match for Sentence \"$raw\".",
            thrower => $self,
        );
    }

    $self->substitute_pronouns( $match );
    $self->{prev_vars}->{$_} = $match->{vars}->{$_} foreach( keys %{ $match->{vars} } );

    push @{$match->{nouns}}, @{$self->{match}->{nouns}};
    $match->{doer}  = $doer if defined $doer;
    return $match;
}

sub build_vocab {
    my $self = shift;
    $self->{vocab} = { help => [ 'vocab', 'vocabulary' ] };
    foreach my $c ( @{$self->{commands}} ) {
        if( $c->{vocab} ) {
            while( my( $k, $v ) = each %{ $c->{vocab} } ) {
                push @{$self->{vocab}->{$k}}, @{$v};
             }
         }
    }
    foreach my $k ( keys %{$self->{vocab}} ) {
         $self->{vocab}->{$k} = [ sort keys %{ { map {$_ => undef} @{$self->{vocab}->{$k}} } } ];
    }
}

sub get_verb_array {
    my $self = shift;
    return $self->{vocab}->{verbs} unless wantarray;
    return @{$self->{vocab}->{verbs}};
} 

1;

