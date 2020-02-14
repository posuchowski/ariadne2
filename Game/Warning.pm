package Warning v2.0.0;

use Moose;
use Method::Signatures;

func warn ( $source, @args ) {
	print STDERR "-" x 40;
	print STDERR "\nGAME WARNING: $source =>\n";
	print STDERR "$_\n" foreach @args;
	print STDERR "-" x 40, "\n";
}

1;

