package Command v0.1.2;
use v5.18;

use strict;
use warnings;
use parent 'Clone';

use constant TRUE  => 1;
use constant FALSE => 0;

use Data::Printer;

sub new {
    my $class = shift;
    my %args  = @_;
    my $self  = {
        verb      => $args{'verb'},
        templates => $args{'templates'},
        vocab     => $args{'vocab'},
        context   => $args{'context'},
        method    => $args{'method'},
        DEBUG     => $args{'DEBUG'} || 0,
        matching_template => undef,
        vars      => undef,  # dictionary of variables assigned
        nouns     => undef,  # list of matching nouns found by Parser
    };
    $self->{vars} = {};  # Store variables from template

    bless( $self, $class );
    return $self;
}

sub reset {
    my $self = shift;
    $self->{matching_template} = undef;
    $self->{vars} = {};
    $self->{nouns} = [];
}

sub matches {
    my( $self, $sent ) = @_;
    my $does_match = 0;
    $self->reset();  # this is a singleton
    foreach my $t ( @{$self->{templates}} ) {
        if( $self->template_match( $t, $sent ) ) {
            $does_match = 1;
            $self->{matching_template} = $t;
            last;
        }
    }
    return $does_match;
}

# Check for special chars indicating non-literal template token
sub _is_literal {
    my( $self, $tok ) = @_;
    return 1 if $tok !~ /[\|\[\$\.]/;
    return 0;
}

sub _is_or {
    my( $self, $tok ) = @_;
    return 1 if $tok =~ /\w+\|/;
    return 0;
}

sub _is_optional {
    my( $self, $tok ) = @_;
    return 1 if $tok =~ /^\[.+\]/;
    return 0;
}

sub _is_yadayada {
    my( $self, $tok ) = @_;
    if( $tok eq '...' ) {
        return 1; #  if $tok eq '...';
    }
    return 0;
}

sub _does_match {
    my( $self, $toke, $test ) = @_;
    # print "COMMAND::_does_match: testing \'$test\' vs. token \'$toke\' => ";
    unless( defined($toke) and defined($test) ) { return 0; };
    if( $self->_is_literal( $test ) ) {
        if( $toke =~ /^$test$/ ) {
            # say "Y";
            return 1;
        }
    }
    elsif( $self->_is_or( $test ) ) {
        my @choices = split /\|/, $test;
        my $m = 0;
        foreach( @choices ) {
            ++$m if $toke =~ /^$_$/;
        }
        if( $m > 0 ) {
            # say "Y";
            return 1;
        }
    }
    # say "N";
    return 0;
}

sub template_match {
    my( $self, $template, $sentence ) = @_;
    my @sent = @{$sentence->tokens};
    my @temp = split /\s+/, $template;

    while( @temp or @sent ) {
        my $test = shift @temp;
        my $optional = 0;
        unless( $test ) {
            $test = "";
        }
        my $varname;
        if( $test =~ /^\$/ ) {
            # say "Variable found";
            ( $varname, $test ) = split ':', $test;
            $varname =~ s/^\$//;
            # say "varname = $varname";
            unless( $test ) {
                my $noun = shift @sent;
                # say "shifted noun $noun";
                if( defined($noun) and $noun =~ /[\w\d]/  ) {
                    # say "noun matched alnum";
                    # say "Command::template_match: setting \'$varname\' to \'$noun\'";
                    $self->{vars}->{$varname} = $noun;
                    next;
                }
                else {
                    # say "noun didn\'t match alnum!";
                    return 0;
                }
            }
        }
        if( $self->_is_optional( $test ) ) {
            $test =~ s/[\[\]]//g;  # strip '[' and ']' from exterior
            $optional = 1;
        }
        if( $self->_is_yadayada( $test ) ) {
            $self->{vars}->{$varname} = join( ' ', @sent ) if $varname;
            @sent = ();
            next;
        }
        if( $self->_does_match( $sent[0], $test ) ) {
            my $val = shift @sent;
            if( $varname ) {
                $self->{vars}->{$varname} = $val;
            }
            # say "Now sent = @sent";
            # say "Now temp = @temp";
            next;
        }
        else {
            last unless $optional;
        }
    }

    # If sentence tokens are left unmatched, return false.
    if( @sent or @temp ) {
        # say "Command: returning 0";
        return 0; # if( @sent or @temp );
    }
    # say "Command returning 1";
    return 1;
}

1;

