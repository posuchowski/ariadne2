package Parser::Template::ErrMsg v1.0.0;

use strict;
use warnings;

use constant TRUE  => 1;
use constant FALSE => 0;

sub new {
    my $class = shift;
    my %args  = @_;
    my $self  = {
        title => 'Parser Error',
        verb => 'ErrMsg',
        err  => $args{'err'},
        msg  => $args{'msg'}, 
        thrower => $args{'thrower'},
        context => $args{'context'},
    };
    bless( $self, $class );
    return $self;
}

1;

