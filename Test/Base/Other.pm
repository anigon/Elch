package Test::Base::Other;

use Elch;
use Test;

has tel => {
    is => "ro",
    default => sub {
        return "test";
#        my $obj = Test->new;
#        return $obj->_tel;
    },
};

has ref_array => {
    is => "rw", isa => "ARRAY",
};

has obj_test => {
    is => "rw", isa => "Test",
};

1; # end of this class
