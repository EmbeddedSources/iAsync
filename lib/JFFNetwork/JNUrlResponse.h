#import <Foundation/Foundation.h>

/**
 A protocol for JFFURLResponse and NSHTTPURLResponse
 */
@protocol JNUrlResponse < NSObject >

@property ( nonatomic, assign ) NSInteger statusCode;
@property ( nonatomic, retain ) NSDictionary* allHeaderFields;
@property ( nonatomic, assign, readonly ) long long expectedContentLength;

@end
