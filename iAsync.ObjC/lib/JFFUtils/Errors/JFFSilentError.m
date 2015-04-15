#import "JFFSilentError.h"

#import "NSError+WriteErrorToNSLog.h"

@implementation JFFSilentError

- (void)writeErrorWithJFFLogger
{
    [self writeErrorToNSLog];
}

@end
