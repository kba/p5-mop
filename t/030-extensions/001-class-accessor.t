#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

use mop;

class ClassAccessorMeta (extends => $::Class) {
    method FINALIZE {

        foreach my $attribute ( values %{ $self->get_all_attributes } ) {
            my $name = $attribute->get_name;
            my $accessor_name = $name;
            $accessor_name =~ s/^\$//;

            $self->add_method(
                $::Method->new(
                    name => $accessor_name,
                    body => sub {
                        mop::internal::instance::set_slot_at( $::SELF, $name, \(shift) ) if @_;
                        mop::internal::instance::get_slot_at( $::SELF, $name )
                    }
                )
            );
        }

        super;
    }
}

class Foo (metaclass => ClassAccessorMeta) {
    has $bar;
    has $baz;
}

is mop::class_of( Foo ), ClassAccessorMeta, '... Foo has the right metaclass';
ok Foo->is_subclass_of( $::Object ), '... Foo is a subtype of Object';
ok Foo->find_method('bar'), '... the bar method was generated for us';
ok Foo->find_method('baz'), '... the baz method was generated for us';

{
    my $foo = Foo->new;
    is mop::class_of( $foo ), Foo, '... we are an instance of Foo';
    ok $foo->isa( Foo ), '... we is-a Foo';
    ok $foo->isa( $::Object ), '... we is-a Object';

    is $foo->bar, undef, '... there is no value for bar';
    is $foo->baz, undef, '... there is no value for baz';

    is exception { $foo->bar( 100 ) }, undef, '... set the bar value without dying';
    is exception { $foo->baz( 'BAZ' ) }, undef, '... set the baz value without dying';

    is $foo->bar, 100, '... and got the expected value for bar';
    is $foo->baz, 'BAZ', '... and got the expected value for bar';
}

{
    my $foo = Foo->new( bar => 100, baz => 'BAZ' );
    is mop::class_of( $foo ), Foo, '... we are an instance of Foo';
    ok $foo->isa( Foo ), '... we is-a Foo';
    ok $foo->isa( $::Object ), '... we is-a Object';

    is $foo->bar, 100, '... and got the expected value for bar';
    is $foo->baz, 'BAZ', '... and got the expected value for bar';

    is exception { $foo->bar( 300 ) }, undef, '... set the bar value without dying';
    is exception { $foo->baz( 'baz' ) }, undef, '... set the baz value without dying';

    is $foo->bar, 300, '... and got the expected value for bar';
    is $foo->baz, 'baz', '... and got the expected value for bar';
}



done_testing;
