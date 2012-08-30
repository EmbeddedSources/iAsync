#import "NSString+Format.h"

@implementation NSString ( Format )

+(id)stringWithFormatCheckNill:( NSString* )format_, ... 
{
    if ( [ format_ length ] == 0 )
    {
        return nil;
    }

    id eachObject_;
    va_list argumentList_;

    va_start( argumentList_, format_ );
    eachObject_ = va_arg(  argumentList_, id );

    while ( eachObject_ )
    {
        if ( ![ eachObject_ isKindOfClass: [ NSObject class ] ] )
        {
            return nil;
        }

        if ( [ [ eachObject_ description ] length ] == 0 )
        {
            return nil;
        }

        eachObject_ = va_arg( argumentList_, id );
    }

    va_start(  argumentList_, format_ );
    return [ [ NSString alloc ] initWithFormat: format_ 
                                     arguments:  argumentList_ ] ;
}

@end
