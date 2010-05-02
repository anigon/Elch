package Test::Attribute::SubClass::A;

use strict;
use warnings;

use Elch::Attribute;
use base qw(Test::Attribute);

sub new       { bless {}, $_[0] }
sub real_name { shift->name }

1; # end of this class
