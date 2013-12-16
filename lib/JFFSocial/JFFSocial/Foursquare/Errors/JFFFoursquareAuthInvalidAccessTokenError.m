#import "JFFFoursquareAuthInvalidAccessTokenError.h"

@implementation JFFFoursquareAuthInvalidAccessTokenError

- (instancetype)init
{
    return [self initWithDescription:NSLocalizedString(@"FOUTSQUARE_INVALID_ACCESS_TOKEN", nil)];
}

@end
