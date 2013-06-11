#import "JFFFacebookRequestPublishingAccessError.h"

@implementation JFFFacebookRequestPublishingAccessError

- (instancetype)init
{
    return [super initWithDescription:NSLocalizedString(@"FACEBOOK_GET_PUBLISH_PERMISSON_ERROR", nil)];
}

@end
