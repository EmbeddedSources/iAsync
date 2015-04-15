#import "JFFOpenApplicationError.h"

@implementation JFFOpenApplicationError

- (instancetype)init
{
    return [self initWithDescription:NSLocalizedString(@"JFFUI_OPEN_APPLICATION_ERROR", nil)];
}

- (void)writeErrorWithJFFLogger
{
}

@end
