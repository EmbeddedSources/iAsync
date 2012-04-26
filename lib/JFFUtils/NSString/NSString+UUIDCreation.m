#import "NSString+UUIDCreation.h"

@implementation NSString (UUIDCreation)

+(NSString*)createUuid
{
    CFUUIDRef uuid_ = CFUUIDCreate( NULL );
    NSString* result_ = (__bridge_transfer NSString *)CFUUIDCreateString( NULL, uuid_ );
    CFRelease( uuid_ );

    return result_;
}

@end
