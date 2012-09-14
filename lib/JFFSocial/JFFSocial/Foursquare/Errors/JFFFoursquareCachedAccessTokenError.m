#import "JFFFoursquareCachedAccessTokenError.h"

@implementation JFFFoursquareCachedAccessTokenError

- (id)init
{
    return [self initWithDescription:NSLocalizedString(@"Cached access token doesn't exist", nil)];
}

@end
