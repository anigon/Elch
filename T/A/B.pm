package T::A::B;
# sub class
use Elch;
extends 'T::A';

# --------------------------------------
# ---- public
sub vergangenheit {}

has name => {
    is => "ro",
    default => sub {
        return "THIS IS name of T::A::B";
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
