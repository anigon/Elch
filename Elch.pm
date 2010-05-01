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


# -----------------------------------------------------
# ---- base method -> like use Exporter

my $new = sub {
    my $class   = shift;
    my (%arg)   = @_;

    my $data_member = {};
    foreach my $key (keys %arg) {
        $data_member->{$key} = $arg{$key};
    }

    # check required data
    my $condition       = __PACKAGE__->DataMemberCondition;
    my $class_condition = $condition->{$class};

    for my $key (keys %{$class_condition}) {
        next unless defined $class_condition->{$key}->{required};

        (exists $data_member->{$key} && defined $data_member->{$key})
                                        or confess "$key is required";
    }

    bless { _data_member => $data_member }, $class;
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

    if (defined $arg->{'required'}) {
        my $condition = __PACKAGE__->DataMemberCondition;
        $condition->{$pkg}{$method} = {required => 1};
        __PACKAGE__->DataMemberCondition($condition);
    }

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
                $self->data_member->{$method} = $value;
            }
        }

        # check isa
        if (defined $arg->{isa} && $is_setter_mode) {
            __PACKAGE__->EnsureIsAllowClassType($arg->{isa}, $value);
        }

        # set default value for lazy
        if (! defined $self->data_member->{$method} && defined $default) {
            my $default_value = $default;
            $default_value    = $default->($self) if ref $default eq 'CODE';
            $self->data_member->{$method}  = $default_value;
        }

        return $self->data_member->{$method};
    };

    no strict 'refs';
    *{"${pkg}::${method}"}   = $routine;
};

my $data_member = sub { shift->{_data_member} };

# -----------------------------------------------------
# ---- public

sub import {
    my $class = shift;
    my ($pkg) = caller;

    no strict 'refs';

    *{"${pkg}::extends"} = $extends;
    *{"${pkg}::has"}     = $has;
    *{"${pkg}::new"}     = $new;

    *{"${pkg}::data_member"} = $data_member;

}

# -----------------------------------------------------
# ---- class method

{
    my $_temporary_data_hash = {};
    sub DataMemberCondition {
        my $dummy     = shift;
        my $condition = shift;

        $_temporary_data_hash = $condition if defined $condition;
        return $_temporary_data_hash;
    }
}

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
