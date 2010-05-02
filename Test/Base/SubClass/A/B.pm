package Test::Base::SubClass::A::B;
# sub class
use Elch;
extends 'Test::Base::SubClass::A';

# --------------------------------------
# ---- public
sub vergangenheit {}

has name => {
    is => "ro",
    default => sub {
        return "THIS IS name of T::Base::SubClass::A::B";
    },
};

has zip => {
    is => "ro",
    default => sub {
        shift->__zip;
    },
};

# --------------------------------------
# ---- private

has __zip => {
    is => "ro",
    default => sub {
        "this is zip";
    },
};

1; # end of this class
