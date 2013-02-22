#import "JFFFacebookLoginFailedCanceledError.h"

@implementation JFFFacebookLoginFailedCanceledError

- (id)init
{
    return [self initWithDescription:NSLocalizedString(@"FACEBOOK_LOGIN_ERROR_CANCELED", nil)];
}

- (void)writeErrorWithJFFLogger
{
}

@end
