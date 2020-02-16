# package Moods {
# 	use Moose;
# 	use Method::Signatures;
#     use enum qw|
# 		IMPERATIVE
# 		INTERROGATIVE
# 		INDICATIVE
# 	|;
# 
# 	method test ( $s ) {
# 		return INTERROGATIVE if $s->pop_token( '?' );
# 		return 0;
# 	}
# }

package Sentence v2.0.0;

use Moose;
use Method::Signatures;


# Raw line from user input
has 'raw' =>      ( isa => 'Str',           is => 'rw', required => 1 );
has 'stripped' => ( isa => 'Str',           is => 'rw', required => 0 );
has 'tokens' =>   ( isa => 'ArrayRef[Str]', is => 'rw', required => 0 );
has 'mood' =>     ( isa => 'Str',           is => 'rw', required => 0 );
has 'strip_words' => ( isa => 'ArrayRef[Str]', is => 'rw', required => 0 );
has 'strip_punct' => ( isa => 'ArrayRef[Str]', is => 'rw', required => 0 );

method BUILD ( $args ) {
	chomp $args->{raw};
	$self->raw( $args->{raw} );
	unless ( defined ( $args->{strip_words} ) ) {
		my $ref = [ 'the', ];
		$self->strip_words( $ref );
	}
	unless ( defined ( $args->{strip_punct} ) ) {
		my $ref = [ '\'', '"', ',', '\.' ];
		$self->strip_punct( $ref );
	}
	$self->_process();
}

method _process () {
	$self->stripped( $self->raw );
	$self->_despace();
	$self->_save_mood();
	$self->_strip_punct();
	$self->_strip_words();
	$self->_tokenize();
}

method _despace () {
	my $despaced = $self->stripped;
	$despaced =~ s/\s+$//;
	$despaced =~ s/^\s+//;
	$self->stripped( $despaced );
}

#FIXME: refactor this into a capture group and one 'if' (OK if it ends up as !? or ?!)
method _save_mood () {
	if ( $self->stripped =~ /\?$/ ) {
		$self->mood( '?' );
		my $s = $self->stripped;
		$s =~ s/\?$//;
		$self->stripped( $s );
		return;
	}
	if ( $self->stripped =~ /!$/ ) {
		$self->mood( '!' );
		my $s = $self->stripped;
		$s =~ s/!$//;
		$self->stripped( $s );
		return;
	}
}

method _strip_punct () {
	return unless $self->strip_punct;
	my $depunct = $self->stripped;
	foreach my $p ( @{$self->strip_punct} ) {
		$depunct =~ s/$p//g;
	}
	$self->stripped( $depunct );
}

method _strip_words () {
	return unless $self->strip_words;
	my $deworded = $self->stripped;
	$deworded =~ s/ $_ / /g foreach @{$self->strip_words};
	$self->stripped( $deworded );
}

method _tokenize () {
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

method remove ( @r ) {
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

method replace ( $old, $new ) {
	my @toks = @{$self->tokens};
	foreach my $t ( @toks ) {
		if( $t eq $old ) {
			$t = $new;
			last;
		}
	}
	$self->tokens( \@toks );
}

__PACKAGE__->meta->make_immutable;

1;

