#import <Foundation/Foundation.h>

@interface NSHTTPCookie (HTTPCookieWithHeader)

+ (instancetype)HTTPCookieWithHeader:(NSString *)header
                                 url:(NSURL *)url;

@end
