#import "JFFAsyncFacebookLogout.h"

#import <FacebookSDK/FacebookSDK.h>

#import <Accounts/Accounts.h>

@interface JFFAsyncFacebookLogout : NSObject <JFFAsyncOperationInterface>
@end

@implementation JFFAsyncFacebookLogout
{
    JFFAsyncOperationInterfaceResultHandler _handler;
@public
    FBSession *_session;
    BOOL _renewSystemAuthorization;
}

#pragma mark - JFFAsyncOperationInterface

- (void)logout
{
    [_session closeAndClearTokenInformation];
    
    //TODO try to fix smart without delay each time
    [self performSelector:@selector(notifyFinished) withObject:nil afterDelay:1.];
}

- (void)asyncOperationWithResultHandler:(JFFAsyncOperationInterfaceResultHandler)handler
                          cancelHandler:(JFFAsyncOperationInterfaceCancelHandler)cancelHandler
                        progressHandler:(JFFAsyncOperationInterfaceProgressHandler)progress
{
    _handler = [handler copy];
    
    if (_renewSystemAuthorization) {
        
        [FBSession renewSystemCredentials:^(ACAccountCredentialRenewResult result, NSError *error) {
            
            [self logout];
        }];
        
        return;
    }
    
    [self logout];
}

- (void)notifyFinished
{
    _handler(@YES, nil);
}

@end

JFFAsyncOperation jffFacebookLogout(FBSession *session, BOOL renewSystemAuthorization)
{
    JFFAsyncOperationInstanceBuilder factory = ^id< JFFAsyncOperationInterface >() {
        JFFAsyncFacebookLogout *object = [JFFAsyncFacebookLogout new];
        
        object->_session = session;
        object->_renewSystemAuthorization = renewSystemAuthorization;
        
        return object;
    };
    
    return buildAsyncOperationWithAdapterFactory(factory);
}
