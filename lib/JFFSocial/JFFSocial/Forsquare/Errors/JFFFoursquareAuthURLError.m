#import "JFFFoursquareAuthURLError.h"

@implementation JFFFoursquareAuthURLError

- (id)init
{
    return [self initWithDescription:NSLocalizedString(@"Bad foursquare auth URL", nil)];
}

@end
