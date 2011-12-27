#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use lib 't/ext/Test-BuilderX';

BEGIN {
    use_ok( 'Test::BuilderX' );
    use_ok( 'Test::BuilderX::TestPlan' );
}

my $tb = Test::BuilderX->new;
is( mop::class_of( $tb ), Test::BuilderX, '... got the expected class' );
ok( $tb->isa( Test::BuilderX ), '... it isa Test::BuilderX' );

# skipping the singleton tests here ...

# skipping the destroy tests here ...

done_testing;


