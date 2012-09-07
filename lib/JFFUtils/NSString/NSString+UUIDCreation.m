#import "NSString+UUIDCreation.h"

@implementation NSString (UUIDCreation)

+ (NSString *)createUuid
{
    CFUUIDRef uuid = CFUUIDCreate( NULL );
    NSString* result = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, uuid);
    CFRelease( uuid );

    return result;
}

@end
