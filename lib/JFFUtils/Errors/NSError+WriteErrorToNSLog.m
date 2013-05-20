#import "NSError+WriteErrorToNSLog.h"

#import "JFFLogger.h"

@implementation NSError (WriteErrorToNSLog)

- (NSString *)errorLogDescription
{
    return [[NSString alloc] initWithFormat:@"NSError : %@, domain : %@ code : %d",
            [self localizedDescription],
            [self domain],
            [self code]];
}

- (void)writeErrorToNSLog
{
    NSLog(@"%@", [self errorLogDescription]);
}

- (void)writeErrorWithJFFLogger
{
    [JFFLogger logErrorWithFormat:@"%@", [self errorLogDescription]];
}

@end
