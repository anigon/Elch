package T::A;
# sub class
use Elch;
extends 'T';

# --------------------------------------
# ---- public

has age => {
    is => "ro",
    default => sub {
        shift->__age;
    },
};

has mobile => {
    is => "ro",
    default => sub {
#        shift->name;
        shift->_tel;
    },
};

# --------------------------------------
# ---- private

has __age => {
    is => "ro",
    default => sub {
        "this is age";
    },
};

1; # end of this class
