package Test::Base::SubClass::A;
# sub class
use Elch;
extends 'Test';

# --------------------------------------
# ---- public

sub gelegenheit {}

has name => {
    is => "ro",
    default => sub {
        return "THIS IS name OF T::Base::SubClass::A";
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
