#import "JFFAsyncFacebookLogout.h"

#import <FacebookSDK/FacebookSDK.h>

@interface JFFAsyncFacebookLogout : NSObject <JFFAsyncOperationInterface>
@end

@implementation JFFAsyncFacebookLogout
{
    JFFDidFinishAsyncOperationCallback _finishCallback;
@public
    FBSession *_session;
    BOOL _renewSystemAuthorization;
}

#pragma mark - JFFAsyncOperationInterface

- (void)logOut
{
    [_session closeAndClearTokenInformation];
    
    //TODO try to fix smart without delay each time
    [self performSelector:@selector(notifyFinished) withObject:nil afterDelay:1.];
}

- (void)asyncOperationWithResultCallback:(JFFDidFinishAsyncOperationCallback)finishCallback
                         handlerCallback:(JFFAsyncOperationChangeStateCallback)handlerCallback
                        progressCallback:(JFFAsyncOperationProgressCallback)progressCallback
{
    _finishCallback = [finishCallback copy];
    
    if (_renewSystemAuthorization) {
        
        [FBSession renewSystemCredentials:^(ACAccountCredentialRenewResult result, NSError *error) {
            
            [self logOut];
        }];
        
        return;
    }
    
    [self logOut];
}

- (void)doTask:(JFFAsyncOperationHandlerTask)task
{
    NSParameterAssert(task <= JFFAsyncOperationHandlerTaskCancel);
}

- (void)notifyFinished
{
    _finishCallback(@YES, nil);
}

@end

JFFAsyncOperation jffFacebookLogout(FBSession *session, BOOL renewSystemAuthorization)
{
    JFFAsyncOperationInstanceBuilder factory = ^id<JFFAsyncOperationInterface>(void) {
        
        JFFAsyncFacebookLogout *object = [JFFAsyncFacebookLogout new];
        
        object->_session = session;
        object->_renewSystemAuthorization = renewSystemAuthorization;
        
        return object;
    };
    
    return buildAsyncOperationWithAdapterFactory(factory);
}
