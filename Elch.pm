package Elch;

use Exporter;
@ISA    = (Exporter);
@EXPORT = qw(has extends);

use Data::Dumper;
my ($class, $file, $line)  = caller;

#no strict 'refs';

sub extends {
    my $super_class = shift;
    eval {
#CORE::require("$super_class");
        "use $super_class";
    };
    if ($@) {
        die ("can't load super class $super_class $@");
    }
}

sub has {
    my $method  = shift;
    my ($arg)   = @_;

    my $default;
    $default    = $arg->{'default'} if exists $arg->{'default'};

    my $routine = sub {

        # check scope
        if ($method =~ /^_/) { # private method
            my ($caller_class_name) = caller();
            $caller_class_name eq $class
                or die "this method cannot be called from other class";
        }

        # check arg
        if (scalar @_ > 1) {
            if ($is eq 'ro') { # read only
                die "this is readonly";
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

    *{"${class}::${method}"}   = $routine;
}

*{"${class}::new"} = sub {
    my $self    = shift;
    my (%arg)   = @_;

    my $member  = {};
    foreach my $key (keys %arg) {
        $member->{$key} = $arg{$key};
    }

    bless $member, $self;
};

1;
