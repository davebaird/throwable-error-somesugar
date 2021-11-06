package Throwable::Error::SomeSugar ;

use strict ;
use warnings ;

use Types::Standard qw( Str ) ;
use Moo ;
use namespace::clean ;

use feature qw(signatures) ;

no warnings qw(experimental::signatures) ;

=pod

=head1 NAME

C<Throwable::Error::SomeSugar> - some sugar for C<Throwable::Error>

=head1 SYNOPSIS

    package MyExceptions ;
    use v5.10 ;
    use warnings ;

    use Moo ;
    extends 'Throwable::Error::SomeSugar' ;

    package SystemError ;
    use Types::Standard qw( Int ) ;
    use Moo ;
    extends 'MyExceptions' ;
    has code           => ( is => 'ro', isa => Int->where('$_ >= 0'), default => 1 ) ;
    has '+description' => ( default => 'A system error' ) ;

    package FileError ;
    use Types::Standard qw( InstanceOf ) ;
    use Moo ;
    extends 'SystemError' ;
    has '+code'        => ( default => 2 ) ;
    has '+description' => ( default => 'A file error' ) ;
    has file           => ( is => 'ro', required => 1, isa => InstanceOf['Path::Tiny'] ) ;

    1 ;

Somewhere else:

    use MyExceptions ;

Anywhere else:

    use Nice::Try ;

    try {
        something() or SystemError->throw("Problem trying to do something",
            code => 7,
            tags => [qw(something broke)],
            ) ;
        }

    catch ( SystemError $e where { $_->has_tags(qw(something broke)) }) {
        fix_it($e) ;
        }

    catch ( SystemError $e where { $_->has_tag('something') }) {
        repair_it($e) ;
        }

    catch ( FileError $e ) {
        warn sprintf "Problem doing something() with file %s: %s",
            $e->file->basename, $e->message ;
        }

    catch ( $e ) {
        die "Give up! $e" ;
        }

=head1 SEE ALSO

https://stackoverflow.com/questions/69729489/best-practice-for-writing-exception-classes-in-modern-perl

=cut

extends 'Throwable::Error' ;

with 'Role::Identifiable::HasTags' ;

has description => ( is => 'ro', isa => Str, required => 1, default => 'Generic exception' ) ;

sub error   { shift->message  }
sub package { shift->stack_trace->frame(0)->package  }
sub file    { shift->stack_trace->frame(0)->filename  }
sub line    { shift->stack_trace->frame(0)->line  }


sub has_tags {
    my ( $self, @wanted ) = @_ ;
    $self->has_tag($_) || return 0 for @wanted ;
    return 1 ;
    }

around BUILDARGS => sub {
    my ( $orig, $class, @args ) = @_ ;
    return +{} unless @args ;
    return $class->$orig(@args) if @args == 1 ;
    unshift @args, 'message' if @args % 2 ;
    return $class->$orig( {@args} ) ;
    } ;

1 ;
