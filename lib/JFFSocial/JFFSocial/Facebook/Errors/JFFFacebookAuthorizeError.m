#import "JFFFacebookAuthorizeError.h"

@implementation JFFFacebookAuthorizeError

- (instancetype)init
{
    return [self initWithDescription:NSLocalizedString(@"FACEBOOK_AUTHORIZATION_FAILED", nil)];
}

- (void)writeErrorWithJFFLogger
{
}

@end
