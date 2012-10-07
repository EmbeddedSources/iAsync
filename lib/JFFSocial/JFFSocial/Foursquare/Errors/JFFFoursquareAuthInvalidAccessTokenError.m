#import "JFFFoursquareAuthInvalidAccessTokenError.h"

@implementation JFFFoursquareAuthInvalidAccessTokenError

- (id)init
{
    return [self initWithDescription:NSLocalizedString(@"FOUTSQUARE_INVALID_ACCESS_TOKEN", nil)];
}

@end
