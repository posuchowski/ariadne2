package Valid v1.0.0;

#
# These are parser special variables and their valid values
# for a command to still match.
#
# To create another variable, just name it the same for use in symbolic refs
#
# 
our $Quantifier = [
    'some', 'all', 'several', 'bunch', 'a',
];

our $Direction = [
    'north', 'south', 'east', 'west',
    'northeast', 'northwest', 'southeast', 'southwest',
    'up', 'upstairs', 'down', 'downstairs',
    'in', 'inside', 'out', 'outside',
    'left', 'right',
    'forward', 'back', 'on', 'onward',  # e.g. 'go on' implemented based on last move direction
];

our $Pronouns = [
    'it', 'him', 'her', 'them', 'some',
];


