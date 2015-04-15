#import "JFFAsyncFacebookDialog.h"

#import <FacebookSDK/FacebookSDK.h>

@interface JFFAsyncFacebookDialog : NSObject <JFFAsyncOperationInterface>
@end

@implementation JFFAsyncFacebookDialog
{
@public
    FBSession    *_session;
    NSDictionary *_parameters;
    NSString     *_message;
    NSString     *_title;
}

- (void)asyncOperationWithResultCallback:(JFFDidFinishAsyncOperationCallback)finishCallback
                         handlerCallback:(JFFAsyncOperationChangeStateCallback)handlerCallback
                        progressCallback:(JFFAsyncOperationProgressCallback)progressCallback
{
    FBWebDialogHandler fbHandler = ^(FBWebDialogResult result,
                                     NSURL *resultURL,
                                     NSError *error) {
        
        if (finishCallback) {
            
            error = (result == FBWebDialogResultDialogNotCompleted)
            ?[JFFAsyncOpFinishedByCancellationError new]
            :nil;
            
            finishCallback(error?nil:@YES, error);
        }
    };
    
    [FBWebDialogs presentRequestsDialogModallyWithSession:_session
                                                  message:_message
                                                    title:_title
                                               parameters:_parameters
                                                  handler:fbHandler];
}

- (void)doTask:(JFFAsyncOperationHandlerTask)task
{
    NSParameterAssert(task <= JFFAsyncOperationHandlerTaskCancel);
}

@end

JFFAsyncOperation jffRequestFacebookDialog(FBSession *session,
                                           NSDictionary *parameters,
                                           NSString *message,
                                           NSString *title)
{
    NSCParameterAssert(session);
    
    JFFAsyncOperationInstanceBuilder factory = ^id< JFFAsyncOperationInterface >() {
        
        JFFAsyncFacebookDialog *dialog = [JFFAsyncFacebookDialog new];
        
        dialog->_session    = session;
        dialog->_parameters = parameters;
        dialog->_message    = message;
        dialog->_title      = title;
        
        return dialog;
    };
    
    return buildAsyncOperationWithAdapterFactory(factory);
}
