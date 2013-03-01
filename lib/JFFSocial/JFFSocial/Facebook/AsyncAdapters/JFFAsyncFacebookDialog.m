#import "JFFAsyncFacebookDialog.h"

#import <FacebookSDK/FacebookSDK.h>

@interface JFFAsyncFacebookDialog : NSObject <JFFAsyncOperationInterface>

@property (nonatomic) FBSession    *session;
@property (nonatomic) NSDictionary *parameters;
@property (nonatomic) NSString     *message;
@property (nonatomic) NSString     *title;

@end

@implementation JFFAsyncFacebookDialog

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
    
    [FBWebDialogs presentRequestsDialogModallyWithSession:self.session
                                                  message:self.message
                                                    title:self.title
                                               parameters:self.parameters
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
        
        dialog.session    = session;
        dialog.parameters = parameters;
        dialog.message    = message;
        dialog.title      = title;
        
        return dialog;
    };
    
    return buildAsyncOperationWithAdapterFactory(factory);
}
