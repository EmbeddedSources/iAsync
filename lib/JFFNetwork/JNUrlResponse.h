#import <Foundation/Foundation.h>

/**
 A protocol for JFFURLResponse and NSHTTPURLResponse
 */
@protocol JNUrlResponse <NSObject>

- (NSInteger)statusCode;
- (NSDictionary *)allHeaderFields;
- (unsigned long long)expectedContentLength;
- (BOOL)hasContentLength;

@end
