#import "JFFAsyncOperationBuilder.h"

#import "JFFAsyncOperationInterface.h"

@interface JFFComplitionHandlerNotifier : NSObject

@property (copy) JFFDidFinishAsyncOperationHandler completionHandler;

-(void)notifyCallbackWithResult:(id)result error:(NSError*)error;

@end

@implementation JFFComplitionHandlerNotifier

-(void)notifyCallbackWithResult:(id)result error:(NSError*)error
{
    if (_completionHandler)
    {
        _completionHandler(result,error);
        _completionHandler = nil;
    }
}

@end

JFFAsyncOperation buildAsyncOperationWithInterface(id< JFFAsyncOperationInterface >asyncObject )
{
    return ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progressCallback_
                                    , JFFCancelAsyncOperationHandler cancelCallback
                                    , JFFDidFinishAsyncOperationHandler doneCallback_ )
    {
        __unsafe_unretained id< JFFAsyncOperationInterface > weakAsyncObject = asyncObject;

        doneCallback_ = [ doneCallback_ copy ];
        __block void (^completionHandler)(id, NSError*) = [ ^( id result_, NSError* error_ )
        {
            //use asyncObject_ in if to own it while waiting result
            if (doneCallback_ && asyncObject)
                doneCallback_( result_, error_ );
        } copy ];
        progressCallback_ = [ progressCallback_ copy ];
        __block void (^progressHandler)( id ) = [ ^( id data_ )
        {
            if ( progressCallback_ )
                progressCallback_(data_);
        } copy ];

        completionHandler = [completionHandler copy];
        JFFObjectFactory factory = ^id()
        {
            JFFComplitionHandlerNotifier *result = [JFFComplitionHandlerNotifier new];
            result.completionHandler = completionHandler;
            return result;
        };

        __block JFFComplitionHandlerNotifier* proxy = (JFFComplitionHandlerNotifier*)
            [JFFSingleThreadProxy singleThreadProxyWithTargetFactory:factory
                                                       dispatchQueue:dispatch_get_current_queue()];

        void (^completionHandlerWrapper)(id, NSError *) = [^(id result,NSError *error)
        {
            progressHandler = nil;
            [proxy notifyCallbackWithResult:result error:error];
            proxy = nil;
        } copy ];

        void (^progressHandlerWrapper)(id) = [^(id data)
        {
            if (progressHandler)
                progressHandler(data);
        }copy];

        [asyncObject asyncOperationWithResultHandler:completionHandlerWrapper
                                     progressHandler:progressHandlerWrapper];

        __block JFFCancelAsyncOperationHandler cancelCallbackHolder_ = [cancelCallback copy];
        return ^(BOOL canceled)
        {
            if (!proxy.completionHandler)
                return;

            [weakAsyncObject cancel:canceled];

            proxy           = nil;
            progressHandler = nil;

            if ( cancelCallbackHolder_ )
            {
                JFFCancelAsyncOperationHandler tmpCallback_ = cancelCallbackHolder_;
                cancelCallbackHolder_ = nil;
                tmpCallback_(canceled);
            }
        };
    };
}
