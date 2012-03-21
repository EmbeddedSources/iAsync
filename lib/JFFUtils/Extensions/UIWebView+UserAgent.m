#import "UIWebView+UserAgent.h"

static NSString* userAgent_ = nil;

@implementation UIWebView (UserAgent)

+(NSString*)userAgent
{
    if ( !userAgent_ )
    {
        UIWebView* webView_ = [ UIWebView new ];
        userAgent_ = [ webView_ stringByEvaluatingJavaScriptFromString: @"navigator.userAgent" ];
    }
    return userAgent_;
}

@end
