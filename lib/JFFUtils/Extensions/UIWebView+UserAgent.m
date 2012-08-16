#import "UIWebView+UserAgent.h"

#include "JGCDAdditions.h"

static NSString* userAgent_;

static NSString* userAgent()
{
    NSString* js_ = @"navigator.userAgent" ;
    UIWebView* webView_ = [ UIWebView new ];
    return [ webView_ stringByEvaluatingJavaScriptFromString: js_ ];
}

@implementation UIWebView (UserAgent)

+(NSString*)userAgent
{
    if ( !userAgent_ )
    {
        userAgent_ = userAgent();
    }
    return userAgent_;
}

//try to remove this to use NSUserDefaults value instead
+(NSString*)threadSafeUserAgent
{
    static dispatch_once_t once_;

    dispatch_once( &once_, ^void( void )
    {
        void (^block_)(void) = ^()
        {
            userAgent_ = userAgent();
        };

        safe_dispatch_sync( dispatch_get_main_queue()
                           , block_ );
    } );

    return userAgent_;
}

+(void)setUserAgentAddition:( NSString* )userAgentAddition_
{
    if ( [ userAgentAddition_ length ] == 0 )
        return;

    NSString* webViewUserAgent_ = [ UIWebView threadSafeUserAgent ];
    NSString* newUserAgent_ = [ [ NSString alloc ] initWithFormat: @"%@ %@"
                               , webViewUserAgent_
                               , userAgentAddition_ ];

    NSDictionary* dictionnary_ = @{ @"UserAgent" : newUserAgent_ };
    [ [ NSUserDefaults standardUserDefaults ] registerDefaults: dictionnary_ ];
}

@end
