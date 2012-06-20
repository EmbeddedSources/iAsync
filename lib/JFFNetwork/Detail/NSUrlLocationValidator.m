#import "NSUrlLocationValidator.h"

@implementation NSUrlLocationValidator

+(BOOL)isValidLocation:( NSString* )location_
{
    if ( nil == location_ )
    {
        return NO;
    }
    else if ( [ location_ isEqualToString: @"" ] )
    {
        return NO;
    }
    else if ( [ location_ hasPrefix: @"/" ] )
    {
        return YES;
    }
    else if ( [ self isLocationValidURL: location_ ] )
    {
        return NO;
    }

    return NO;
}

+(BOOL)isLocationValidURL:( NSString* )location_
{
    NSURL* url_ =  [ NSURL URLWithString: location_ ];
    return ( nil != url_ );
}

@end
