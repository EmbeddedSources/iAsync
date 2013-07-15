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

- (void)asyncOperationWithResultHandler:(JFFAsyncOperationInterfaceResultHandler)handler
                          cancelHandler:(JFFAsyncOperationInterfaceCancelHandler)cancelHandler
                        progressHandler:(JFFAsyncOperationInterfaceProgressHandler)progress
{
    FBWebDialogHandler fbHandler = ^(FBWebDialogResult result,
                                     NSURL *resultURL,
                                     NSError *error) {
        
        if (result == FBWebDialogResultDialogNotCompleted) {
            
            if (cancelHandler)
                cancelHandler(YES);
        }
        
        if (handler) {
            
            handler(error?nil:@YES, nil);
        }
    };
    
    [FBWebDialogs presentRequestsDialogModallyWithSession:_session
                                                  message:_message
                                                    title:_title
                                               parameters:_parameters
                                                  handler:fbHandler];
}

- (void)cancel:(BOOL)canceled
{
}

@end

JFFAsyncOperation jffRequestFacebookDialog(FBSession *session,
                                           NSDictionary *parameters,
                                           NSString *message,
                                           NSString *title)
{
    assert(session);
    
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
