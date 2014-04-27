#import "NSError+WriteErrorToNSLog.h"

#import "JFFLogger.h"

@implementation NSError (WriteErrorToNSLog)

- (NSString *)errorLogDescription
{
    NSString *strCode = [@([self code]) descriptionWithLocale:nil];
    
    return [[NSString alloc] initWithFormat:@"%@ : %@, domain : %@ code : %@",
            [self class],
            [self localizedDescription],
            [self domain],
            strCode];
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
