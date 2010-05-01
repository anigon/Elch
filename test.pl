#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;
use lib qw(/home/anigon/Elch);

use T::A::B;
use T;
use T::A;
use Z;

#print "T $_\n"       for (keys %{T::});
#print "T::A $_\n"    for (keys %{T::A::});
#print "T::A::B $_\n" for (keys %{T::A::B::});

print "--------------------------------------\n";
my $sub_a_class = T::A->new;
print $sub_a_class->age, "\n";
print $sub_a_class->mobile, "\n";

print "--------------------------------------\n";
my $sub_b_class = T::A::B->new(
                    name => "name by constructor",
                  );
print $sub_b_class->zip, "\n";

print "--------------------------------------\n";
my $t_class = T->new(
                name => 'anigon',
                address => "address by constructor",
              );
print $t_class->name, "\n";
print $t_class->address, "\n";
print $t_class->tel, "\n";

print "--------------------------------------\n";
print $t_class->test, "\n";
#print $t_class->_test, "\n"; #-> exception must be thrown

print "--------------------------------------\n";
my $z_class = Z->new;
$t_class->z($z_class);
print $t_class->z->tel, "\n";

my @array = qw(a b c);
#$t_class->z->isa_test("scalar"); #-> exception must be thrown
$t_class->z->isa_test(\@array);
print $t_class->z->isa_test, "\n";

#$t_class->z(T::A->new); #-> exception must be thrown
$t_class->z->isa_test_t(T::A->new);

print $sub_a_class->name, "\n";
print $sub_b_class->name, "\n";

exit;
