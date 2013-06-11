#import "JFFFoursquareAuthURLError.h"

@implementation JFFFoursquareAuthURLError

- (instancetype)init
{
    return [self initWithDescription:NSLocalizedString(@"FOUTSQUARE_BAD_AUTH_URL", nil)];
}

@end
