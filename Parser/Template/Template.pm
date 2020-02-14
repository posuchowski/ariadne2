package Template v2.0.0;

use Moose;
use Method::Signatures;

has 'name'     => ( isa => 'Str',     is => 'rw', required => 0 );
has 'template' => ( isa => 'Str',     is => 'rw', required => 1 );
has 'vars' 	   => ( isa => 'HashRef', is => 'rw', required => 0 );

method BUILD ( $args ) {
	$self->vars( {} )
		unless defined( $self->vars );
	$self->name( $self->template )
		unless defined( $self->name );
}

method reset () {
	$self->vars( {} );
}

method matches ( Sentence $sentence ) {
    my @tokens   = @{$sentence->tokens};
    my @template = split /\s+/, $self->template;

    while( @template or @tokens ) {
        my $test = shift @template;
        my $optional = 0;
        unless( $test ) {
            $test = ""; 	# disallow undef
        }
        my $varname;
        if( $test =~ /^\$/ ) {
            ( $varname, $test ) = split ':', $test;
            $varname =~ s/^\$//;
            unless( $test ) { 
                my $varval = shift @tokens;
                if( defined($varval) and $varval =~ /[\w\d]/  ) {
                    $self->vars->{$varname} = $varval;
                    next;
                }
                else {
                    return 0;
                }
            }
        }
        if( $self->_is_optional( $test ) ) {
            $test =~ s/[\[\]]//g;  # strip '[' and ']' from exterior
            $optional = 1;
        }
        if( $self->_is_yadayada( $test ) ) {
            $self->vars->{$varname} = join( ' ', @tokens ) if $varname;
            @tokens = ();
            next;
        }
        if( $self->_does_match( $tokens[0], $test ) ) {
            my $val = shift @tokens;
            if( $varname ) {
                $self->vars->{$varname} = $val;
            }
            next;
        }
        else {
            last unless $optional;
        }
    }

    # If sentence tokens are left unmatched, return false.
    if( @tokens or @template ) {
        return 0;
    }
    return 1;
}

method _does_match ( $token, Str $test ) {
	return 0 unless ( defined( $token ) and defined( $test ) );
	return 1 if $self->_is_literal( $test) and $token =~ /^$test$/;
    if( $self->_is_or( $test ) ) {
        my @choices = split /\|/, $test;
        my $m = 0;
        foreach( @choices ) {
            ++$m if $token =~ /^$_$/;
        }
		return 1 if ( $m > 0 );
    }
    return 0;
}

# Check for special chars indicating non-literal template token
method _is_literal ( Str $token ) {
    return 1 if $token !~ /[\|\[\$\.]/;
    return 0;
}

# Check for token like word1|word2|word3|...
method _is_or ( Str $token ) {
    return 1 if $token =~ /\w+\|/;
    return 0;
}

# Surrounded by brackets is optional
method _is_optional ( Str $token ) {
    return 1 if $token =~ /^\[.+\]/;
    return 0;
}

# ... matches any text greedily
method _is_yadayada ( Str $token ) {
	return 1 if $token eq '...';
    return 0;
}

1;

