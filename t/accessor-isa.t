use strictures 1;
use Test::More;
use Test::Fatal;

sub run_for {
  my $class = shift;

  my $obj = $class->new(less_than_three => 1);

  is($obj->less_than_three, 1, 'initial value set');

  like(
    exception { $obj->less_than_three(4) },
    qr/4 is not less than three/, 'exception thrown on bad set'
  );

  is($obj->less_than_three, 1, 'initial value remains after bad set');

  my $ret;

  is(
    exception { $ret = $obj->less_than_three(2) },
    undef, 'no exception on correct set'
  );

  is($ret, 2, 'correct setter return');
  is($obj->less_than_three, 2, 'correct getter return');

  is(exception { $class->new }, undef, 'no exception with no value');
  like(
    exception { $class->new(less_than_three => 12) },
    qr/12 is not less than three/, 'exception thrown on bad constructor arg'
  );
}

{
  package Foo;

  use Moo;

  has less_than_three => (
    is => 'rw',
    isa => sub { die "$_[0] is not less than three" unless $_[0] < 3 }
  );
}

run_for 'Foo';

{
  package Bar;

  use Sub::Quote;
  use Moo;

  has less_than_three => (
    is => 'rw',
    isa => quote_sub q{ die "$_[0] is not less than three" unless $_[0] < 3 }
  );
}

run_for 'Bar';

{
  package Baz;

  use Sub::Quote;
  use Moo;

  has less_than_three => (
    is => 'rw',
    isa => quote_sub(
      q{ die "$_[0] is not less than ${word}" unless $_[0] < $limit },
      { '$limit' => \3, '$word' => \'three' }
    )
  );
}

run_for 'Baz';

done_testing;