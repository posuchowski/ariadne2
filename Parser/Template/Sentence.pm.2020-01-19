use Method::Signatures;

package Moods {
    use enum qw|
        IMPERATIVE
        INTERROGATIVE
        INDICATIVE
    |;

    method test ( $s ) {
        return INTERROGATIVE if $s->pop_token( '?' );
        return 0;
    }
}

package Sentence v2.0.0 {
    my $raw;        # Line as returned from the user input
    my $stripped;   # Chomp, remove articles, etc
    my $tokens;     # Arrayref of words and symbols
    my $mood;       # Not necessarily grammar moods

    my @strip_words = ( 'the' );

    method _process ( $text ) {
        $self->_strip_words();
        $self->_tokenize();
    }

    method _strip_words {
        return unless @strip_words;
        $raw =~ s/$_// foreach @strip_words;
    }

    method _tokenize ( void ) {
        my @tmp  = split /\s+/, $self->stripped;
        my @fin;

        if( $self->stripped =~ /"/ ) {
            my $in_quote = 0;
            while( @tmp ) {
                my $text = shift @tmp;
                $in_quote = 1 if $text =~ /"[^"]+$/;
                while( $in_quote ) {
                    my $t = shift @tmp;
                    $in_quote = 0 if $t =~ /"/;
                    $text .= " $t";
                }
                push @fin, $text;
            }
        }
        else {
            @fin = @tmp;
        }
        $self->tokens( \@fin );
    }

    sub remove {
        my( $self, @r ) = @_;
        foreach my $r( @r ) {
            unless( $r =~ /\s/ ) {
                my @toks = grep { $_ ne $r } @{$self->tokens};
                $self->tokens( \@toks );
            }
            else {
                my $i = 0;
                while( $i < @{$self->tokens} - @r ) {
                    my $test = join ' ', @{$self->tokens}[$i..($i+@r)];
                    if( $test eq $r ) {
                        my @new = @{$self->tokens};
                        splice @new, $i, @r+1;
                        $self->tokens( \@new );
                        last;
                    }
                    $i++;
                }
            }
        }
    }

    sub replace {
        my( $self, $old, $new ) = @_;
        my @toks = @{$self->tokens};
        foreach my $t ( @toks ) {
            if( $t eq $old ) {
                $t = $new;
                last;
            }
        }
        $self->tokens( \@toks );
    }

} # end package Sentence

### RETURN ###
1;
###  TRUE  ###

