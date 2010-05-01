package Elch;

use strict;
use warnings;
use Carp;

# -----------------------------------------------------
# ---- constant

use constant TRUE      => 1;
use constant FALSE     => undef;
use constant PROTECTED => 10;
use constant PRIVATE   => 20;


my $new = sub {
    my $self    = shift;
    my (%arg)   = @_;

    my $member  = {};
    foreach my $key (keys %arg) {
        $member->{$key} = $arg{$key};
    }

    bless $member, $self;
};

my $extends = sub {
    my $super_class = shift;
    my ($pkg)       = caller;
    eval {
        use Module::Load;
        load $super_class;
        no strict 'refs';
        @{"${pkg}::ISA"} = $super_class;
    };
    if ($@) {
        confess "can't load super class $super_class $@";
    }
};

my $has = sub {
    my $method  = shift;
    my ($arg)   = @_;
    my ($pkg)   = caller;

    my $default;
    $default    = $arg->{'default'} if exists $arg->{'default'};

    my $routine = sub {
        my $self  = shift;

        my $is_setter_mode = (scalar @_ >= 1 ? TRUE : FALSE);
        my $value          = shift;

        # check scope
        my ($caller_class_name) = caller();
        __PACKAGE__->EnsureIsAllowScope($pkg, $method, $caller_class_name);

        # check read/write permission
        if ($is_setter_mode) {
            if ($arg->{is} eq 'ro') { # read only
                confess "this is readonly";
            } else {                  # read write (* default)
                $self->{$method} = $value;
            }
        }

        # check isa
        if (defined $arg->{isa} && $is_setter_mode) {
            __PACKAGE__->EnsureIsAllowClassType($arg->{isa}, $value);
        }

        # set default value for lazy
        if (! defined $self->{$method} && defined $default) {
            my $default_value = $default;
            $default_value    = $default->($self) if ref $default eq 'CODE';
            $self->{$method}  = $default_value;
        }

        return $self->{$method};
    };

    no strict 'refs';
    *{"${pkg}::${method}"}   = $routine;
};

# -----------------------------------------------------
# ---- public

sub import {
    my $class = shift;
    my ($pkg) = caller;

    no strict 'refs';
    *{"${pkg}::new"}     = $new;
    *{"${pkg}::has"}     = $has;
    *{"${pkg}::extends"} = $extends;
}

# -----------------------------------------------------
# ---- class method

sub EnsureIsAllowClassType {
    my $dummy = shift;
    my ($required_class_type, $value) = @_;

    defined $value
        or confess "value is undefined";

    my $value_class_type    = ref $value || $value;
    $value_class_type =~ /^$required_class_type/
        or confess "class type must be $required_class_type. ".
                   "this class type is $value_class_type";

    return TRUE;
}

sub EnsureIsAllowScope {
    my $dummy = shift;
    my ($pkg, $method, $caller_class_name) = @_;

    return TRUE unless $method =~ /^_(_?)/;

    my $scope = ($1 ? PRIVATE : PROTECTED);

    if ($scope == PRIVATE) {
        $caller_class_name eq $pkg
            or confess "$method cannot be called from other class";

    } elsif ($scope == PROTECTED) {
        return if $caller_class_name eq $pkg; # itself

        my $is_subclass = FALSE;

        no strict 'refs';
        for (@{"${caller_class_name}::ISA"}) {
            next unless $_ =~ /^$pkg$/;
            $is_subclass = TRUE; last;
        }
        use strict 'refs';

        $is_subclass
            or confess "$method cannot be called from other package";
    }

    return TRUE;
}

1; # end of this class
