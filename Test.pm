package Test;
# super class
use Elch;
requires qw(gelegenheit vergangenheit);

# --------------------------------------
# ---- public

has name => {
    'is' => "ro", required => 1,
};

has address => {
    'is' => "ro", required => 1,
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

has other => {
    is => "rw", isa => "Test::Base::Other",
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
