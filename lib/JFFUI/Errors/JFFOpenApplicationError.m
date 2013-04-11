#import "JFFOpenApplicationError.h"

@implementation JFFOpenApplicationError

- (id)init
{
    return [self initWithDescription:NSLocalizedString(@"JFFUI_OPEN_APPLICATION_ERROR", nil)];
}

- (void)writeErrorWithJFFLogger
{
}

@end
