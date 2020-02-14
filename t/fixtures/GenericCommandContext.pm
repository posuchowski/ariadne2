package GenericCommandContext v2.0.0;

sub new {
	return bless {}, shift;
}

# Override 'can' the same it was done in the original
# Intangible::Disambiguator kludge object, so that
# we can do anything.
sub can {
    no warnings;
    my( $self, $what ) = @_;
	$self->{what} = $what;
    return 1;
}

sub AUTOLOAD {
	our $AUTOLOAD;
	my( $self, $template ) = @_;
	print STDERR "$AUTOLOAD called with template ", 
		$template->name, "\n";
	$self->{what} = (split /::/, $AUTOLOAD)[1];
	return $self->{what};
}

1;

