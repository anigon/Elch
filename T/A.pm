package T::A;

use Elch;
extends 'T';

has age => {
    is => "ro",
    default => sub {
        shift->_age;
    },
};

has _age => {
    is => "ro",
    default => sub {
        "this is age";
    },
};

1; # end of perl-module
