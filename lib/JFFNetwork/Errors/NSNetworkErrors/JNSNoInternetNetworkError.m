#import "JNSNoInternetNetworkError.h"

@implementation JNSNoInternetNetworkError

+ (BOOL)isMineNSNetworkError:(NSError *)error
{
    return [error isNetworkError];
}

- (instancetype)init
{
    return [self initWithDescription:NSLocalizedString(@"JNETWORK_NO_INTERNET_ERROR", nil)];
}

- (void)writeErrorWithJFFLogger
{
    [self writeErrorToNSLog];
}

@end
