#import "JNSNoInternetNetworkError.h"

@implementation JNSNoInternetNetworkError

+ (BOOL)isMineNSNetworkError:(NSError *)error
{
    BOOL hasNSURLDomain = [[error domain] isEqualToString:NSURLErrorDomain];
    return hasNSURLDomain && [error code] == kCFURLErrorNotConnectedToInternet;
}

- (id)init
{
    return [self initWithDescription:NSLocalizedString(@"JNETWORK_NO_INTERNET_ERROR", nil)];
}

@end
