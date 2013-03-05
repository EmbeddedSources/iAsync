#import <Foundation/Foundation.h>

/**
 A protocol for JFFURLResponse and NSHTTPURLResponse
 */
@protocol JNUrlResponse < NSObject >

@property (nonatomic) NSInteger statusCode;
@property (nonatomic, strong) NSDictionary *allHeaderFields;
@property (nonatomic, readonly) unsigned long long expectedContentLength;

@end
