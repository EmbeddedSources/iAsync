#import "JFFLocationServicesDisabledError.h"

@implementation JFFLocationServicesDisabledError

- (id)init
{
    return [self initWithDescription:NSLocalizedString(@"JFF_LOCALIZATION_SERVICE_NOT_ENABLED", nil)];
}

@end
