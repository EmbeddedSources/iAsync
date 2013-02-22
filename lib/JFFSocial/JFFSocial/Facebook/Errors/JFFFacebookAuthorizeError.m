#import "JFFFacebookAuthorizeError.h"

@implementation JFFFacebookAuthorizeError

- (id)init
{
    return [self initWithDescription:NSLocalizedString(@"FACEBOOK_AUTHORIZATION_FAILED", nil)];
}

- (void)writeErrorWithJFFLogger
{
}

@end
