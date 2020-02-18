#
# Groups a bunch of templates and knows which method to call on whatever
# context will execute it.
#
package Command v2.0.0;

use Moose;
use Method::Signatures;
use Game::Warning;

use constant True  => 1;
use constant False => 0;

has 'name' 		=> ( required => 1, isa => 'Str' );  # unambiguous command name
has 'method'    => ( required => 1, isa => 'Str' );  # name of method to call
has 'templates' => ( required => 1, isa => 'ArrayRef[Template]' );
has 'context'   => ( required => 0, isa => 'GameObject' );
has 'matching_template_index' => ( required => 0, isa => 'Int' );

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
			return True;
		}
	}
	return False;
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

