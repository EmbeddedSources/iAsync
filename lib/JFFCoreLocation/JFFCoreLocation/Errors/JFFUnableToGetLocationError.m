#import "JFFUnableToGetLocationError.h"

@implementation JFFUnableToGetLocationError

- (instancetype)init
{
    return [self initWithDescription:NSLocalizedString(@"JFF_UNABLE_TO_GET_LOCATION_ERROR", nil)];
}

- (void)writeErrorWithJFFLogger
{
}

@end
