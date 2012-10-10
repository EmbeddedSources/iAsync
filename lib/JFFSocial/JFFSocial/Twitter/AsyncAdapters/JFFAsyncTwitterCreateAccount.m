#import "JFFAsyncTwitterCreateAccount.h"

#import "JFFTwitterAccountCanceledCreationError.h"

#import <Twitter/Twitter.h>

@interface JFFAsyncTwitterCreateAccount : NSObject <JFFAsyncOperationInterface>
@end

@implementation JFFAsyncTwitterCreateAccount

- (void)asyncOperationWithResultHandler:(JFFAsyncOperationInterfaceHandler)handler
                        progressHandler:(void(^)(id))progress
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
        if (result == TWTweetComposeViewControllerResultCancelled)
        {
            [controller dismissViewControllerAnimated:NO completion:^()
            {
                [controller.view removeFromSuperview];
                if(handler)
                    handler(nil, [JFFTwitterAccountCanceledCreationError new]);
            }];
        }
        else
        {
            NSParameterAssert( NO );
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
