#!/usr/bin/perl

use strict;
use warnings;
use lib qw(/home/anigon/Elch);
use Test::More qw(no_plan);
use Test::Exception;

BEGIN {
    use_ok 'Test::Attribute';
    use_ok 'Test::Attribute::SubClass::A';
    use_ok 'Test::Attribute::Other';
}
require_ok 'Test::Attribute';
require_ok 'Test::Attribute::SubClass::A';
require_ok 'Test::Attribute::Other';

can_ok('Test::Attribute', 'new');
can_ok('Test::Attribute::SubClass::A', 'new');
can_ok('Test::Attribute::Other', 'new');

diag 'Test::Attribute::Other';
{
    dies_ok(sub { Test::Attribute::Other->new->name },
                            'execute protected method : name');
}

diag 'Test::Attribute::SubClass::A';
{
    can_ok 'Test::Attribute::SubClass::A', 'real_name';
    ok(Test::Attribute::SubClass::A->new->real_name);
    diag(Test::Attribute::SubClass::A->new->real_name);
}

diag 'Test::Attribute';
{
    my $obj = Test::Attribute->new;
    ok $obj->age(37);
    is $obj->age, 37, 'accessor age';

    ok $obj->test, 'call private method from same scope';
    dies_ok(sub { $obj->_test }, 'execute private method : _test');
    dies_ok(sub { $obj->_age }, 'execute private method : _age');
    dies_ok(sub { $obj->name }, 'execute protected method : name');
}

exit;
