#import "asyncXMLParsers.h"

//JTODO test
JFFAsyncOperationBinder xmlDocumentWithDataAsyncBinder( void )
{
    return ^JFFAsyncOperation( NSData* data_ )
    {
        return ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progressCallback_
                                        , JFFCancelAsyncOperationHandler cancelCallback_
                                        , JFFDidFinishAsyncOperationHandler doneCallback_ )
        {
            NSError* parseError_ = nil;
            //STODO parse on separate thread and test
            CXMLDocument* document_ = xmlDocumentWithData( data_, &parseError_ );
            
            if ( doneCallback_ )
                doneCallback_( document_, parseError_ );
            
            return JFFStubCancelAsyncOperationBlock;
        };
    };
}

//JTODO test
JFFAsyncOperationBinder xmlDocumentWithStringAsyncBinder( void )
{
    return ^JFFAsyncOperation( NSString* str_ )
    {
        JFFAsyncOperationBinder binder_ = xmlDocumentWithDataAsyncBinder();
        //JTODO remove conversation from string to data
        NSData* data_ = [ str_ dataUsingEncoding: NSUTF8StringEncoding ];
        return binder_( data_ );
    };
}
