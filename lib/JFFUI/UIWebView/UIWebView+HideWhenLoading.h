#import <UIKit/UIKit.h>

@interface UIWebView (HideWhenLoading)

//warning: this method broke delegate property of UIWebView
-(void)hideWhenLoadingHTMLString:( NSString* )html_string_;

@end
