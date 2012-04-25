#import <UIKit/UIKit.h>

@interface UIWebView (UserAgent)

+(NSString*)userAgent;
+(NSString*)threadSafeUserAgent;

+(void)setUserAgentAddition:( NSString* )userAgentAddition_;

@end
