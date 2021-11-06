# NAME

`Throwable::Error::SomeSugar` - some sugar for `Throwable::Error`

# SYNOPSIS

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

# SEE ALSO

https://stackoverflow.com/questions/69729489/best-practice-for-writing-exception-classes-in-modern-perl
