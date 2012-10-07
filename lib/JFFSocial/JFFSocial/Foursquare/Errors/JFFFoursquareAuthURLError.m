#import "JFFFoursquareAuthURLError.h"

@implementation JFFFoursquareAuthURLError

- (id)init
{
    return [self initWithDescription:NSLocalizedString(@"FOUTSQUARE_BAD_AUTH_URL", nil)];
}

@end
