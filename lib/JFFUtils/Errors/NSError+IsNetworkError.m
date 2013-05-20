#import "NSError+IsNetworkError.h"

@implementation NSError (IsNetworkError)

- (BOOL)isNetworkError
{
    if (![[self domain] isEqualToString:NSURLErrorDomain])
        return NO;
    
    NSInteger code = [self code];
    return code == kCFURLErrorNotConnectedToInternet
    || code == kCFURLErrorTimedOut;
}

@end
