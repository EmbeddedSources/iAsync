#import "JFFAsyncFoursquaerLogin.h"

#import <JFFUI/Categories/UIApplication+OpenApplicationAsyncOp.h>

#import "JFFFoursquareSessionStorage.h"

//TODO remove this class
@interface JFFAsyncFoursquaerLogin : NSObject <JFFAsyncOperationInterface>

@property (copy, nonatomic) JFFCancelAsyncOperation cancelOperation;

@end

@implementation JFFAsyncFoursquaerLogin
{
    JFFCancelAsyncOperation _cancelOperation;
}

- (void)asyncOperationWithResultHandler:(JFFAsyncOperationInterfaceResultHandler)handler
                          cancelHandler:(JFFAsyncOperationInterfaceCancelHandler)cancelHandler
                        progressHandler:(JFFAsyncOperationInterfaceProgressHandler)progress
{
    handler = [handler copy];
    
    UIApplication *application = [UIApplication sharedApplication];
    NSURL *url = [[JFFFoursquareSessionStorage authURLString] toURL];
    JFFAsyncOperation loader = [application asyncOperationWithApplicationURL:url];
    
    _cancelOperation = loader(nil, nil, ^(id result, NSError *error) {
        handler(result, error);
    });
}

- (void)cancel:(BOOL)canceled
{
    if (_cancelOperation) {
        _cancelOperation(canceled);
    }
}

@end

JFFAsyncOperation jffFoursquareLoginLoader(void)
{
    JFFAsyncOperationInstanceBuilder factory = ^id< JFFAsyncOperationInterface >() {
        return [JFFAsyncFoursquaerLogin new];
    };
    
    return buildAsyncOperationWithAdapterFactory(factory);
}