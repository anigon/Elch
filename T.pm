package T;
# super class
use Elch;

# --------------------------------------
# ---- public

has name => {
    'is' => "ro",
};

has tel => {
    'is' => "ro",
    default => sub {
        return shift->_tel;
    },
};

has test => {
    'is' => "rw",
    default => sub {
        return shift->__test;
    },
};

has z => {
    is => "rw", isa => "Z",
};

# --------------------------------------
# ---- protected

has _tel => {
    'is' => "rw",
    default => sub {
        return "this is protected tel";
    },
};

# --------------------------------------
# ---- private

has __test => {
    'is' => "rw",
    default => sub {
        return "this is test string";
    },
};

1; # end of this class
