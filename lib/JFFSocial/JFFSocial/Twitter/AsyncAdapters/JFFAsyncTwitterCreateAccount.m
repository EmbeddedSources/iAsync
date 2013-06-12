#import "JFFAsyncTwitterCreateAccount.h"

#import "JFFTwitterAccountCanceledCreationError.h"

#import <Twitter/Twitter.h>

@interface JFFAsyncTwitterCreateAccount : NSObject <JFFAsyncOperationInterface>
@end

@implementation JFFAsyncTwitterCreateAccount

- (void)asyncOperationWithResultHandler:(JFFAsyncOperationInterfaceResultHandler)handler
                          cancelHandler:(JFFAsyncOperationInterfaceCancelHandler)cancelHandler
                        progressHandler:(JFFAsyncOperationInterfaceProgressHandler)progress
{
    handler  = [handler  copy];
    progress = [progress copy];
    
    TWTweetComposeViewController *viewController = [TWTweetComposeViewController new];
    
    //hide the tweet screen
    viewController.view.hidden = YES;

    UIViewController *controller = [UIViewController new];

    //fire tweetComposeView to show "No Twitter Accounts" alert view on iOS5.1
    viewController.completionHandler = ^(TWTweetComposeViewControllerResult result)
    {
        if (result == TWTweetComposeViewControllerResultCancelled) {
            
            //TODO Up through iOS 6, when using TWTweetComposeViewController and SLComposeViewController (the latter only for Twitter and Weibo, but not Facebook), if the caller supplies a completionHandler, the supplied completionHandler is responsible for dismissing the view controller. As of iOS 7, if the app links against the iOS 7 SDK, the view controller will dismiss itself even if the caller supplies a completionHandler. To avoid this, the caller’s completionHandler should not dismiss the view controller.
            
            [controller dismissViewControllerAnimated:NO completion:^() {
                
                [controller.view removeFromSuperview];
                if(handler)
                    handler(nil, [JFFTwitterAccountCanceledCreationError new]);
            }];
        } else {
            assert(NO);
        }
    };

    UIApplication* app = [UIApplication sharedApplication];
    [app.keyWindow addSubview: controller.view];
    [controller presentViewController:viewController animated:NO completion:nil];
    
    //hide the keyboard
    [viewController.view endEditing:YES];
}

- (void)cancel:(BOOL)canceled
{
}

@end

JFFAsyncOperation jffCreateTwitterAccountLoader()
{
    JFFAsyncOperationInstanceBuilder factory = ^id< JFFAsyncOperationInterface >() {
        return [JFFAsyncTwitterCreateAccount new];
    };
    return buildAsyncOperationWithAdapterFactory(factory);
}
