package T;

use Elch;

# --------------------------------------
# ---- external

has name => { # public method
    'is' => "ro",
};

has test => { # public method
    'is' => "rw",
    default => sub {
        return shift->_test;
    },
};

# --------------------------------------
# ---- internal 

has _test => { # private method
    'is' => "rw",
    default => sub {
        return "this is test string";
    },
};

1; # end of perl-module
