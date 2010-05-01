#!/usr/bin/perl -w

use strict;
use lib qw(/home/anigon/Elch);
use T;
use T::A;
use T::A::B;
use Z;

#print "T $_\n"       for (keys %{T::});
#print "T::A $_\n"    for (keys %{T::A::});
#print "T::A::B $_\n" for (keys %{T::A::B::});

my $sub_a_class = T::A->new;
print $sub_a_class->age, "\n";
print $sub_a_class->mobile, "\n";

my $sub_b_class = T::A::B->new;
print $sub_b_class->zip, "\n";

my $obj = T->new(name => 'anigon');
print $obj->name, "\n";
print $obj->tel, "\n";

print "--------------------------------------\n";
print $obj->test, "\n";
print "--------------------------------------\n";
#print $obj->_test, "\n";

my $z_class = Z->new;
print $z_class->tel, "\n";

exit;
