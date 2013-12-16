#import <Foundation/Foundation.h>

@interface NSError (IsNetworkError)

- (BOOL)isNetworkError;
- (BOOL)isActiveCallError;

@end
