#import "JFFLocationServicesDisabledError.h"

@implementation JFFLocationServicesDisabledError

- (instancetype)init
{
    return [self initWithDescription:NSLocalizedString(@"JFF_LOCALIZATION_SERVICE_NOT_ENABLED", nil)];
}

- (void)writeErrorWithJFFLogger
{
}

@end
