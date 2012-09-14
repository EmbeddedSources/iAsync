#import "JFFFoursquareAuthInvalidAccessTokenError.h"

@implementation JFFFoursquareAuthInvalidAccessTokenError

- (id)init
{
    return [self initWithDescription:NSLocalizedString(@"Invalid access token", nil)];
}

@end
