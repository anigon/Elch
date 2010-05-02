#!/usr/bin/perl

use strict;
use warnings;
use lib qw(/home/anigon/Elch);
use Test::More qw(no_plan);
use Test::Exception;

#print "T $_\n"       for (keys %{T::});
#print "T::A $_\n"    for (keys %{T::A::});
#print "T::A::B $_\n" for (keys %{T::A::B::});

BEGIN {
    use_ok 'Test';
    use_ok 'Test::Base::SubClass::B';
    use_ok 'Test::Base::SubClass::A::B';
    use_ok 'Test::Base::SubClass::A';
    use_ok 'Test::Base::Other';
}
require_ok 'Test';
require_ok 'Test::Base::SubClass::B';
require_ok 'Test::Base::SubClass::A::B';
require_ok 'Test::Base::SubClass::A';
require_ok 'Test::Base::Other';

can_ok('Test', 'new');
can_ok('Test::Base::SubClass::B', 'new');
can_ok('Test::Base::SubClass::A::B', 'new');
can_ok('Test::Base::SubClass::A', 'new');
can_ok('Test::Base::Other', 'new');

diag 'Test::Base::SubClass::A';
{
    my $obj = Test::Base::SubClass::A->new;
    ok $obj->age,    'call public method : age';
    ok $obj->mobile, 'call public method : mobile';
    ok $obj->name,   'call public method : name';
    diag $obj->age;
    diag $obj->mobile;
    diag $obj->name;
}

diag 'Test::Base::SubClass::A::B';
{
    my $obj = Test::Base::SubClass::A::B->new(
                    name => "name by constructor",
              );
    ok $obj->zip,  'call public method : zip';
    ok $obj->name, 'call public method : name';
    diag $obj->zip;
    diag $obj->name;
}

diag 'Test';
{
    my $obj = Test->new(
                    name => 'anigon',
                    address => "address by constructor",
                  );
    ok $obj->name,    'call public method : name';
    ok $obj->address, 'call public method : address';
    ok $obj->tel,     'call public method : tel';
    ok $obj->test,    'call public method : test';
    dies_ok(sub { $obj->_test }, 'execute private method : _test');
}

diag 'Test with Test::Base::Other';
{
    my $obj   = Test->new(
                      name    => 'anigon',
                      address => "address by constructor",
                );
    my $o_obj = Test::Base::Other->new;
    dies_ok(sub { $obj->other(Test::Base::SubClass::A->new) },
                        'set Test::Base::SubClass::A object');
    ok $obj->other($o_obj), 'set Test::Base::Other object';
    diag $obj->other->tel;

    dies_ok(sub { $obj->other->ref_array("scalar") },
                        'set Scalar : ref_array');
    ok $obj->other->ref_array([qw(a b c)]),
                        'set ref ARRAY : ref_array';
    diag $obj->other->ref_array;

    ok $obj->other->obj_test(Test->new(name=>'test', address=>'address'));
    diag $obj->other->obj_test;
}

exit;
