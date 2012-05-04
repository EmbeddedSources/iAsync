#import "JFFDataLoadersTools.h"

JFFAsyncOperation jTmpFileLoaderWithChunkedDataLoader( JFFAsyncOperation chunkedDataLoader_ )
{
    chunkedDataLoader_ = [ chunkedDataLoader_ copy ];
    return ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progressCallback_
                                    , JFFCancelAsyncOperationHandler cancelCallback_
                                    , JFFDidFinishAsyncOperationHandler doneCallback_ )
    {
        __block NSString* filePath_   = nil;
        __block NSFileHandle* handle_ = nil;

        __block void (^closeFile_)() = ^()
        {
            [ handle_ closeFile ];
            handle_ = nil;
        };

        __block void (^closeAndRemoveFile_)() = ^()
        {
            closeFile_();

            if ( filePath_ )
                [ [ NSFileManager defaultManager ] removeItemAtPath: filePath_
                                                              error: nil ];
        };

        progressCallback_ = [ progressCallback_ copy ];
        JFFAsyncOperationProgressHandler progressWrapperCallback_ = ^( id progressInfo_ )
        {
            if ( !handle_ )
            {
                filePath_ = [ NSString createUuid ];
                filePath_ = [ NSString cachesPathByAppendingPathComponent: filePath_ ];
                [ [ NSFileManager defaultManager ] createFileAtPath: filePath_
                                                           contents: nil
                                                         attributes: nil ];
                handle_ = [ NSFileHandle fileHandleForWritingAtPath: filePath_ ];
            }

            //STODO write in separate thread only ( dispatch_io_create_with_path )
            [ handle_ writeData: progressInfo_ ];

            if ( progressCallback_ )
                progressCallback_( progressInfo_ );
        };

        cancelCallback_ = [ cancelCallback_ copy ];
        JFFCancelAsyncOperationHandler cancelWrapperCallback_ = ^( BOOL canceled_ )
        {
            closeAndRemoveFile_();

            if ( cancelCallback_ )
                cancelCallback_( canceled_ );
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
                doneCallback_( result_, error_ );
        };

        return chunkedDataLoader_( progressWrapperCallback_
                                  , cancelWrapperCallback_
                                  , doneWrapperCallback_ );
    };
}
