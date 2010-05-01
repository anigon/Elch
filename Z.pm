package Z;

use Elch;
use T;

has tel => {
    is => "ro",
    default => sub {
        return "test";
#        my $obj = T->new;
#        return $obj->_tel;
    },
};

has isa_test => {
    is => "rw", isa => "ARRAY",
};

has isa_test_t => {
    is => "rw", isa => "T",
};

1; # end of this class
