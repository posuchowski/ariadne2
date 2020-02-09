#!/usr/bin/perl
use Valid;
use strict;
no strict 'refs';

print "Start.\n";

my $var = 'Direction';
my $list = eval( "\$Valid::$var" );
if( $@ ) {
    print "Eval error: $@\n";
}
for my $val( @$list ) {
    print "$val\n";
}

my $new = \$var;
print "New deferences to ", $$new, "\n";

$new = "Valid::$var";
print "New deferences to ", $$new, "\n";

print "\nAgain: new = $new\n";
for my $val( @{$$new} ) {
    print "$val\n";
}
print "End.\n";

