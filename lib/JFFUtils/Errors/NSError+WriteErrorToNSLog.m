#import "NSError+WriteErrorToNSLog.h"

#import "JFFLogger.h"

@implementation NSError (WriteErrorToNSLog)

- (NSString *)errorLogDescription
{
    return [[NSString alloc] initWithFormat:@"%@ : %@, domain : %@ code : %ld",
            [self class],
            [self localizedDescription],
            [self domain],
            (long)[self code]];
}

- (void)writeErrorToNSLog
{
    NSLog(@"only log - %@", [self errorLogDescription]);
}

- (void)writeErrorWithJFFLogger
{
    [JFFLogger logErrorWithFormat:@"%@", [self errorLogDescription]];
}

@end
