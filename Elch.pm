package Elch;

use strict;
use warnings;
use Carp;

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

sub _can_execute {
    my ($pkg, $method, $caller_class_name) = @_;

    return unless $method =~ /^_(_?)/;

    my $scope = ($1 ? PRIVATE : PROTECTED);

    if ($scope == PRIVATE) {
        $caller_class_name eq $pkg
            or confess "$method cannot be called from other class";

    } elsif ($scope == PROTECTED) {
        return if $caller_class_name eq $pkg; # itself

        my $is_subclass = 0;

        no strict 'refs';
        for (@{"${caller_class_name}::ISA"}) {
            next unless $_ =~ /^$pkg$/;
            $is_subclass++; last;
        }
        use strict 'refs';

        $is_subclass
            or confess "$method cannot be called from other package";
    }
}

my $has = sub {
    my $method  = shift;
    my ($arg)   = @_;
    my ($pkg)   = caller;

    my $default;
    $default    = $arg->{'default'} if exists $arg->{'default'};

    my $routine = sub {

        # check scope
        my ($caller_class_name) = caller();
        &_can_execute($pkg, $method, $caller_class_name);
#        if ($method =~ /^_(_?)/) {
#            my $is_private          = $1;
#            my ($caller_class_name) = caller();
#
#            if ($is_private) {
#                $caller_class_name eq $pkg
#                    or confess "$method cannot be called from other class";
#
#            } else { # protected method
#                if ($caller_class_name ne $pkg) {
#                    my $is_subclass = 0;
#
#                    no strict 'refs';
#                    for (@{"${caller_class_name}::ISA"}) {
#                        next unless $_ =~ /^$pkg$/;
#                        $is_subclass++; last;
#                    }
#                    use strict 'refs';
#
#                    $is_subclass
#                        or confess "$method cannot be called from other package";
#                }
#            }
#        }

        # check arg
        if (scalar @_ > 1) {
            if ($arg->{is} eq 'ro') { # read only
                confess "this is readonly";
            } else { # read write (* default)
                $_[0]->{$method} = $_[1];
            }
        }

        # set default value for lazy
        if (! defined $_[0]->{$method} && defined $default) {
            my $default_value = $default;
            $default_value    = $default->($_[0]) if ref $default eq 'CODE';
            $_[0]->{$method}  = $default_value;
        }

        return $_[0]->{$method};
    };

    no strict 'refs';
    *{"${pkg}::${method}"}   = $routine;
};

sub import {
    my $class = shift;
    my ($pkg) = caller;

    no strict 'refs';
    *{"${pkg}::new"}     = $new;
    *{"${pkg}::has"}     = $has;
    *{"${pkg}::extends"} = $extends;
}

1; # end of this class
