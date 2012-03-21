#import "JFFAsyncOperationBuilder.h"

//JTODO test it
JFFAsyncOperation buildAsyncOperationWithInterface( id< JFFAsyncOperationInterface > asyncObject_ )
{
    return ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progressCallback_
                                    , JFFCancelAsyncOperationHandler cancelCallback_
                                    , JFFDidFinishAsyncOperationHandler doneCallback_ )
    {
        __unsafe_unretained id< JFFAsyncOperationInterface > weakAsyncObject__ = asyncObject_;

        doneCallback_ = [ doneCallback_ copy ];
        __block void (^completionHandler_)( id, NSError* ) = [ ^( id result_, NSError* error_ )
        {
            //use asyncObject_ in if to own it while waiting result
            if ( doneCallback_ && asyncObject_ )
                doneCallback_( result_, error_ );
        } copy ];
        progressCallback_ = [ progressCallback_ copy ];
        __block void (^progressHandler_)( id ) = [ ^( id data_ )
        {
            //use asyncObject_ in if to own it while waiting result
            if ( progressCallback_ )
                progressCallback_( data_ );
        } copy ];

        void (^completionHandlerWrapper_)( id, NSError* ) = ^( id result_, NSError* error_ )
        {
            progressHandler_ = nil;
            if ( completionHandler_ )
            {
                completionHandler_( result_, error_ );
                completionHandler_ = nil;
            }
        };

        void (^progressHandlerWrapper_)( id ) = ^( id data_ )
        {
            if ( progressHandler_ )
                progressHandler_( data_ );
        };

        [ asyncObject_ asyncOperationWithResultHandler: completionHandlerWrapper_
                                       progressHandler: progressHandlerWrapper_ ];

        __block JFFCancelAsyncOperationHandler cancelCallbackHolder_ = [ cancelCallback_ copy ];
        return ^( BOOL canceled_ )
        {
            if ( !completionHandler_ )
                return;

            [ weakAsyncObject__ cancel: canceled_ ];

            completionHandler_ = nil;
            progressHandler_   = nil;

            if ( cancelCallbackHolder_ )
            {
                JFFCancelAsyncOperationHandler tmpCallback_ = cancelCallbackHolder_;
                cancelCallbackHolder_ = nil;
                tmpCallback_( canceled_ );
            }
        };
    };
}
