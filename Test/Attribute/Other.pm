package Test::Attribute::Other;
# test module for Protected

use strict;
use warnings;
use Test::Attribute;

sub new  { bless {}, $_[0] }
sub name { return Test::Attribute->new->name }

1; # end of this class
