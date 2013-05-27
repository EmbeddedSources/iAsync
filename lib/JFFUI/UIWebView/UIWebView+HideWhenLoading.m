#import "UIWebView+HideWhenLoading.h"

@class JUIWebViewDelegateProxy;

@interface UIWebView (HideWhenLoadingInternal)

@property (nonatomic) JUIWebViewDelegateProxy *proxy;

@end

@implementation UIWebView (HideWhenLoadingInternal)

@dynamic proxy;

+ (void)load
{
    jClass_implementProperty(self, @"proxy");
}

@end

@interface JUIWebViewDelegateProxy : NSObject < UIWebViewDelegate >

@property (nonatomic) UIWebView *webView;

@end

@implementation JUIWebViewDelegateProxy

#pragma mark UIWebViewDelegate

- (void)didFinishLoading
{
    self.webView.hidden = NO;
    
    self.webView.delegate = nil;
    self.webView.proxy = nil;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self didFinishLoading];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self didFinishLoading];
}

@end

@implementation UIWebView (HideWhenLoading)

- (void)hideWhenLoadingHTMLString:( NSString* )htmlString
{
    if (!self.proxy) {
        self.proxy = [JUIWebViewDelegateProxy new];
        self.proxy.webView = self;
    }
    self.delegate = self.proxy;
    self.hidden = YES;
    [self loadHTMLString:htmlString baseURL:nil];
}

@end
