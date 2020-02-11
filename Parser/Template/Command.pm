package Command v2.0.0;

use Moose;
use Method::Signatures;
use Data::Printer;

extends 'Clone';

use constant TRUE  => 1;
use constant FALSE => 0;

has 'DEBUG'     => ( isa => 'Bool',				  required => 0 );
has 'verb' 		=> ( isa => 'Str', 				  required => 1 );
has 'templates' => ( isa => 'ArrayRef(Template)', required => 1 );
has 'vocab'     => ( isa => 'ArrayRef(Str)', 	  required => 1 );
has 'context'   => ( isa => 'GameObject',         required => 0 );
has 'method'    => ( isa => 

has 'matching_template' => ( isa => 'Template',   required => 0 );
has 'vars'				=> ( isa => 'HashRef',	  required => 0 );
has 'matching_nouns'    => ( isa => 'ArrayRef',   required => 0 );				

method BUILD() {
	$self->vars = {};
	$self->matching_template = undef;
}

method reset() {
    $self->matching_template = undef;
    $self->vars  = {};
    $self->nouns = [];
}

1;

