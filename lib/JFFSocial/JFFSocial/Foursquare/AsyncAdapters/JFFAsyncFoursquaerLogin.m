#import "JFFAsyncFoursquaerLogin.h"

#import "JFFFoursquareSessionStorage.h"

#import <JFFUI/Categories/UIApplication+OpenApplicationAsyncOp.h>

JFFAsyncOperation jffFoursquareLoginLoader(void)
{
    return ^JFFAsyncOperationHandler(JFFAsyncOperationProgressCallback progressCallback,
                                     JFFAsyncOperationChangeStateCallback stateCallback,
                                     JFFDidFinishAsyncOperationCallback doneCallback) {
        
        UIApplication *application = [UIApplication sharedApplication];
        NSURL *url = [[JFFFoursquareSessionStorage authURLString] toURL];
        JFFAsyncOperation loader = [application asyncOperationWithApplicationURL:url];
        
        return loader(progressCallback,
                      stateCallback,
                      doneCallback);
    };
}