#
# Groups a bunch of templates and knows which method to call on whatever
# context will execute it.
#
package Command v2.0.0;

use Moose;
use Method::Signatures;
use Game::Warning;

use constant TRUE  => 1;
use constant FALSE => 0;

has 'name' 		=> ( required => 1, isa => 'Str' );  # unambiguous command name
has 'method'    => ( required => 1, isa => 'Str' );  # name of method to call
has 'templates' => ( isa => 'ArrayRef[Template]', required => 1 );

# What object is going to receive and execute the command
# This is assigned by the engine... unless preassigned?
has 'context'   => ( isa => 'GameObject',         required => 0 );

has 'matching_template_index' => ( isa => 'Int',   required => 0 );

method BUILD() {
	$self->matching_template_index = -1;
}

method reset() {
    $self->matching_template_index = -1;
}

method matches( Sentence $sentence ) {
	for ( my $i=0; $i<@{$self->templates}; $i++ ) {
		if ( $self->templates->[$i]->matches( $sentence ) ) {
			if ( $self->matching_template_index > 0 ) {
				Warning::warn( "In Command " . $self->name,
					"More than one template matches";
					"First match: ",
					$self->templates->[ $self->matching_template_index ]->template,
					"Also matched: ",
					$self->templates->[ $i ]->template
				);
			}
			$self->matching_template_index( $i );
		}
	}
}

# 
# For example, call:
# GameLocation->walk( { Direction => 'north' } );
#
method exec( $context ) {
	no strict 'refs';
	if ( $context->can( $self->method ) ) {
		$context->${$self->method}(
			$self->templates[ $self->matching_template_index ]->vars
		);
	}
	else {
		$context->default( $self );
	}
}

1;

