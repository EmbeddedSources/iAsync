#import <Foundation/Foundation.h>

@interface NSError (WriteErrorToNSLog)

- (NSString *)errorLogDescription;

- (void)writeErrorToNSLog;
- (void)writeErrorWithJFFLogger;

@end
