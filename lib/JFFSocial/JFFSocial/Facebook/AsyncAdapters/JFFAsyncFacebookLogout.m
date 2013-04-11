#import "JFFAsyncFacebookLogout.h"

#import <FacebookSDK/FacebookSDK.h>

@interface JFFAsyncFacebookLogout : NSObject <JFFAsyncOperationInterface>

@property (nonatomic) FBSession *facebookSession;
@property (nonatomic, copy) JFFAsyncOperationInterfaceResultHandler handler;

@end


@implementation JFFAsyncFacebookLogout
{
    JFFAsyncOperationInterfaceResultHandler _handler;
}

#pragma mark - JFFAsyncOperationInterface

- (void)asyncOperationWithResultHandler:(JFFAsyncOperationInterfaceResultHandler)handler
                          cancelHandler:(JFFAsyncOperationInterfaceCancelHandler)cancelHandler
                        progressHandler:(JFFAsyncOperationInterfaceProgressHandler)progress
{
    [self.facebookSession closeAndClearTokenInformation];
    
    _handler = [handler copy];
    //TODO try to fix smart without delay each time
    [self performSelector:@selector(notifyFinished) withObject:nil afterDelay:1.];
}

- (void)notifyFinished
{
    _handler(@YES, nil);
}

- (void)cancel:(BOOL)canceled
{
}

@end

JFFAsyncOperation jffFacebookLogout(FBSession *facebook)
{
    JFFAsyncOperationInstanceBuilder factory = ^id< JFFAsyncOperationInterface >() {
        JFFAsyncFacebookLogout *object = [JFFAsyncFacebookLogout new];
        
        object.facebookSession = facebook;
        return object;
    };
    
    return buildAsyncOperationWithAdapterFactory(factory);
}
