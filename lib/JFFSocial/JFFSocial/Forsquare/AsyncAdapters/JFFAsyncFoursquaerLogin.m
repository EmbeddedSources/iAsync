#import "JFFAsyncFoursquaerLogin.h"

#import <JFFUI/Extensions/UIApplication+OpenApplicationAsyncOp.h>

#import "JFFForsquareSessionStorage.h"

@interface JFFAsyncFoursquaerLogin : NSObject <JFFAsyncOperationInterface>

@property (copy, nonatomic) JFFCancelAsyncOperation cancelOperation;

@end


@implementation JFFAsyncFoursquaerLogin

- (void)asyncOperationWithResultHandler:(JFFAsyncOperationInterfaceHandler)handler
                        progressHandler:(JFFAsyncOperationInterfaceProgressHandler)progress
{
    handler = [handler copy];
    
    UIApplication *application = [UIApplication sharedApplication];
    NSURL *url = [[JFFForsquareSessionStorage authURLString] toURL];
    JFFAsyncOperation loader = [application asyncOperationWithApplicationURL:url];
    
    loader(nil, nil, ^(id result, NSError *error)
           {
               handler (result, error);
           });
    
}

- (void)cancel:(BOOL)canceled
{
    if (self.cancelOperation) {
        self.cancelOperation (canceled);
    }
}

@end


JFFAsyncOperation jffFoursquareLoginLoader ()
{
    JFFAsyncFoursquaerLogin *obj = [JFFAsyncFoursquaerLogin new];
    
    return buildAsyncOperationWithInterface(obj);
}