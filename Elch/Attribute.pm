package Elch::Attribute;

use strict;
use warnings;
use Carp;
use Attribute::Handlers;
no warnings 'redefine';

sub UNIVERSAL::Protected : ATTR(CODE) {
    my ($package, $symbol) = @_;

    my $method_name = *{$symbol}{NAME};
    my $master_code = *{$symbol}{CODE};

    my $wrap_method = sub {
        my ($caller_package) = caller;
        my $is_sub_class;

        no strict 'refs';
        for my $super_class (@{"${caller_package}::ISA"}) {
            next unless $super_class eq $package;
            $is_sub_class++; last;
        }

        $is_sub_class
           or confess "${package}::${method_name} is protected";

        &{$master_code};
    };

    no strict 'refs';
    *{"${package}::${method_name}"} = $wrap_method;
}

sub UNIVERSAL::Private : ATTR(CODE) {
    my ($package, $symbol) = @_;

    my $method_name = *{$symbol}{NAME};
    my $master_code = *{$symbol}{CODE};

    my $wrap_method = sub {
        my ($caller_package) = caller;
        $caller_package eq $package
           or confess "${package}::${method_name} is private";

        &{$master_code};
    };

    no strict 'refs';
    *{"${package}::${method_name}"} = $wrap_method;
}

1; # end of this class
