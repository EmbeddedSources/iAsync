#import "NSString+Format.h"

@implementation NSString ( Format )

+(id)stringWithFormatCheckNill:( NSString* )format_, ... 
{
    if ( [ format_ length ] == 0 )
    {
        return nil;
    }

    id eachObject_;
    va_list argument_list_;

    va_start(argument_list_, format_ );
    eachObject_ = va_arg( argument_list_, id );

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

        eachObject_ = va_arg( argument_list_, id );
    }

    va_start( argument_list_, format_ );
    return [ [ NSString alloc ] initWithFormat: format_ 
                                     arguments: argument_list_ ] ;
}

@end
