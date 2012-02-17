#import "UIWebView+UserAgent.h"

static NSString* user_agent_ = nil;

@implementation UIWebView (UserAgent)

+(NSString*)userAgent
{
   if ( !user_agent_ )
   {
      UIWebView* web_view_ = [ UIWebView new ];
      user_agent_ = [ web_view_ stringByEvaluatingJavaScriptFromString: @"navigator.userAgent" ];
   }
   return user_agent_;
}

@end
