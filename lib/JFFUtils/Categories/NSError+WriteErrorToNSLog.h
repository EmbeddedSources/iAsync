#import <Foundation/Foundation.h>

@interface NSError (WriteErrorToNSLog)

- (void)writeErrorToNSLog;
- (void)writeErrorWithJFFLogger;

@end
