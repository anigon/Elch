package Test::Base::SubClass::B;
# sub class
use Elch;
extends 'Test';

# --------------------------------------
# ---- public

has name => {
    is => "ro",
    default => sub {
        return "THIS IS name OF T::Base::SubClass::B";
    },
};

has age => {
    is => "ro",
    default => sub {
        shift->__age;
    },
};

has mobile => {
    is => "ro",
    default => sub {
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
