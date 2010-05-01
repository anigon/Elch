package T::A::B;
# sub class
use Elch;
extends 'T::A';

# --------------------------------------
# ---- public

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
