#import "UIWebView+UserAgent.h"

#import <JFFUtils/JGCDAdditions.h>

static NSString *globalUserAgent;

static NSString *userAgent()
{
    NSString *js = @"navigator.userAgent";
    UIWebView *webView = [UIWebView new];
    return [webView stringByEvaluatingJavaScriptFromString:js];
}

@implementation UIWebView (UserAgent)

+ (NSString *)userAgent
{
    if (!globalUserAgent) {
        globalUserAgent = userAgent();
    }
    return globalUserAgent;
}

//try to remove this to use NSUserDefaults value instead
+ (NSString *)threadSafeUserAgent
{
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        void (^block)(void) = ^() {
            globalUserAgent = userAgent();
        };
        
        if ([NSThread isMainThread]) {
            block();
        } else {
            dispatch_sync(dispatch_get_main_queue(), block);
        }
    });
    
    return globalUserAgent;
}

+ (void)setUserAgentAddition:(NSString *)userAgentAddition
{
    if ([userAgentAddition length] == 0)
        return;
    
    NSString *webViewUserAgent = [UIWebView threadSafeUserAgent];
    NSString *newUserAgent = [[NSString alloc] initWithFormat:@"%@ %@",
                              webViewUserAgent,
                              userAgentAddition];
    
    NSDictionary *dictionnary = @{ @"UserAgent": newUserAgent };
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionnary];
}

@end
