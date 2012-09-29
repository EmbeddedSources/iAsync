#import "JFFDataLoadersTools.h"

#import "JFFRestKitError.h"

JFFAsyncOperation jTmpFileLoaderWithChunkedDataLoader( JFFAsyncOperation chunkedDataLoader_ )
{
    chunkedDataLoader_ = [ chunkedDataLoader_ copy ];
    return ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progressCallback_
                                    , JFFCancelAsyncOperationHandler cancelCallback
                                    , JFFDidFinishAsyncOperationHandler doneCallback_ )
    {
        __block NSString* filePath_   = nil;
        __block NSFileHandle* handle = nil;

        __block void (^closeFile_)() = ^()
        {
            [ handle closeFile ];
            handle = nil;
        };

        __block void (^closeAndRemoveFile_)() = ^()
        {
            closeFile_();

            if ( filePath_ )
                [ [ NSFileManager defaultManager ] removeItemAtPath: filePath_
                                                              error: nil ];
        };

        progressCallback_ = [ progressCallback_ copy ];
        JFFAsyncOperationProgressHandler progressWrapperCallback_ = ^( id progressInfo )
        {
            if ( !handle )
            {
                filePath_ = [ NSString createUuid ];
                filePath_ = [ NSString cachesPathByAppendingPathComponent: filePath_ ];
                [ [ NSFileManager defaultManager ] createFileAtPath: filePath_
                                                           contents: nil
                                                         attributes: nil ];
                handle = [ NSFileHandle fileHandleForWritingAtPath: filePath_ ];
            }

            //STODO write in separate thread only ( dispatch_io_create_with_path )
            [handle writeData:progressInfo];
            
            if ( progressCallback_ )
                progressCallback_( progressInfo );
        };
        
        cancelCallback = [cancelCallback copy];
        JFFCancelAsyncOperationHandler cancelWrapperCallback_ = ^( BOOL canceled_ )
        {
            closeAndRemoveFile_();

            if ( cancelCallback )
                cancelCallback( canceled_ );
        };

        JFFDidFinishAsyncOperationHandler doneWrapperCallback_ = ^( id response_, NSError* error_ )
        {
            id result_ = response_;

            if ( response_ )
            {
                result_ = filePath_;
                closeFile_();
            }

            if ( doneCallback_ )
            {
                if ( result_ == nil && error_ == nil )
                {
                    error_ = [ JFFRestKitEmptyFileResponseError new ];
                }
                doneCallback_( result_, error_ );
            }
        };

        return chunkedDataLoader_( progressWrapperCallback_
                                  , cancelWrapperCallback_
                                  , doneWrapperCallback_ );
    };
}
