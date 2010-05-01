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
    my $class_condition  = __PACKAGE__->PackageCondition($class);
    my $member_condition = $class_condition->{data_member};

    for my $key (keys %{$member_condition}) {
        next unless defined $member_condition->{$key}{required};

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

    my $condition        = __PACKAGE__->PackageExtendsCondition;
    my $target_condition = __PACKAGE__->HasRegisteredAsSuperClass(
                               $condition, $super_class
                           );

    if (defined $target_condition) {
        $target_condition->{$pkg} = {};
    } else {
        $condition->{$super_class}{$pkg} = {};
    }

    __PACKAGE__->PackageExtendsCondition($condition);
};


my $requires = sub {
    return if scalar @_ == 0;
    my ($pkg) = caller;

    my $condition = __PACKAGE__->PackageCondition($pkg);
    $condition->{required_members} = \@_;
    __PACKAGE__->PackageCondition($pkg, $condition);
};

my $has = sub {
    my $method  = shift;
    my ($arg)   = @_;
    my ($pkg)   = caller;

    if (defined $arg->{'required'}) {
        my $condition = __PACKAGE__->PackageCondition($pkg);
        $condition->{data_member}{$method}{required} = 1;
        __PACKAGE__->PackageCondition($pkg, $condition);
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
sub INIT  {
    # check required members
    my $condition = __PACKAGE__->PackageCondition;

    for my $pkg (keys %{$condition}) {
        next unless exists $condition->{$pkg}{required_members};

        __PACKAGE__->EnsureHasRequiredMember(
                $condition->{extends}, $pkg,
                $condition->{$pkg}{required_members}
        );
    }

}

sub import {
    my $class = shift;
    my ($pkg) = caller;

    no strict 'refs';
    *{"${pkg}::extends"}  = $extends;
    *{"${pkg}::requires"} = $requires;
    *{"${pkg}::has"}      = $has;
    *{"${pkg}::new"}      = $new;

    *{"${pkg}::data_member"} = $data_member;
}

# -----------------------------------------------------
# ---- class method

{
    my $_package_condition = {};

    sub PackageCondition {
        my $dummy     = shift;
        my $pkg       = shift;
        my $condition = shift;

        unless (defined $pkg) {
            $_package_condition = $condition if defined $condition;
            return $_package_condition;
        }

        $_package_condition->{$pkg} = {}
                unless exists $_package_condition->{$pkg};

        $_package_condition->{$pkg} = $condition if defined $condition;
        return $_package_condition->{$pkg};
    }

    sub PackageExtendsCondition {
        my $dummy     = shift;
        my $condition = shift;

        $_package_condition->{extends} = {}
                unless exists $_package_condition->{extends};

        $_package_condition->{extends} = $condition if defined $condition;
        return $_package_condition->{extends};
    }
}

sub HasRegisteredAsSuperClass {
    my $dummy     = shift;

    my $condition = shift;
    my $class     = shift;

    for my $registered_class (keys %{$condition}) {
        if (ref $condition->{$registered_class} eq 'HASH') {
            my $r = __PACKAGE__->HasRegisteredAsSuperClass(
                                $condition->{$registered_class},
                                $class
                        );
            return $r if defined $r;
        }

        next unless exists $condition->{$class};
        return $condition->{$class};
    }

    return FALSE;
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

sub EnsureHasRequiredMember {
    my $dummy            = shift;
    my $condition        = shift;
    my $class            = shift;
    my $required_members = shift;

    my $has_member = FALSE;
    for my $member (@{$required_members}) {
        my $tree = __PACKAGE__->HasRegisteredAsSuperClass(
                           $condition, $class
                   );
        $has_member = __PACKAGE__->CanRequiredMember($tree, $member);
        $has_member or confess "$member is required";
        $has_member = FALSE;
    }
}

sub CanRequiredMember {
    my $dummy  = shift;
    my $tree   = shift;
    my $member = shift;

    my $has_member = FALSE;
    for my $class (keys %{$tree}) {
        if (ref $tree->{$class} eq 'HASH') {
            $has_member = __PACKAGE__->CanRequiredMember(
                            $tree->{$class},
                            $member
                          );
            return $has_member if defined $has_member;
        }
# TODO change check routine, do something instead of new
        next unless $class->new->can($member);
        return TRUE;
    }

    return FALSE;
}


1; # end of this class
