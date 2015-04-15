#import "JFFFoursquareCachedAccessTokenError.h"

@implementation JFFFoursquareCachedAccessTokenError

- (instancetype)init
{
    return [self initWithDescription:NSLocalizedString(@"FOUTSQUARE_CACHED_ACCESS_TOKEN_DOESNOT_EXIST", nil)];
}

@end
