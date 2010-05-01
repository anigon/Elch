package Z;

use Elch;
use T;

has tel => {
    is => "ro",
    default => sub {
        my $obj = T->new;
        return $obj->_tel;
    },
};

1; # end of this class
