#!/usr/bin/perl -w

use strict;
use lib qw(/home/anigon/Elch);
use T;
use T::A;

my $sub_class = T::A->new;
print $sub_class->age;

my $obj = T->new(name => 'anigon');
#print $obj->name, "\n";

print "--------------------------------------\n";
print $obj->test, "\n";
print "--------------------------------------\n";
#print $obj->_test, "\n";


#subname test, sub { print "test\n" };

#test;

exit;
