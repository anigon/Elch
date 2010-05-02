package Test::Attribute;

use Elch::Attribute;

# --------------------------------------------
# ---- public
{
    my %_arg;
    sub new {
        my $class = shift;
        bless \%_arg, $class;
    }
}

sub test { shift->_test(@_) }
sub age  { shift->_age(@_) }

# --------------------------------------------
# ---- protected
sub name : Protected {
    return "this is protected method : name";
}

# --------------------------------------------
# ---- private

sub _age : Private  {
    my $self  = shift;
    my $value = shift;
    $self->{age} = $value if defined $value;
    return $self->{age};
}

sub _test : Private { print "test\n" }

1; # end of this class
