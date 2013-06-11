#import "NSUrlLocationValidator.h"

@implementation NSUrlLocationValidator

+ (BOOL)isValidLocation:(NSString *)location
{
    if ( nil == location )
    {
        return NO;
    }
    else if ( [ location isEqualToString: @"" ] )
    {
        return NO;
    }
    else if ( [ location hasPrefix: @"/" ] )
    {
        return YES;
    }
    else if ( [ self isLocationValidURL: location ] )
    {
        return NO;
    }

    return NO;
}

+ (BOOL)isLocationValidURL:(NSString *)location
{
    NSURL *url =  [NSURL URLWithString:location];
    return (nil != url);
}

@end
