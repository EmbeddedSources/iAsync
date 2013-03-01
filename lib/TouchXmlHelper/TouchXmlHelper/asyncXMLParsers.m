#import "asyncXMLParsers.h"

#import "jRestKitXMLTools.h"
#import <JFFAsyncOperations/JFFAsyncOperationsPredefinedBlocks.h>

//JTODO test
JFFAsyncOperationBinder xmlDocumentWithDataAsyncBinder( void )
{
    return ^JFFAsyncOperation( NSData* data_ ) {
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
    return ^JFFAsyncOperation(NSString *str) {
        JFFAsyncOperationBinder binder = xmlDocumentWithDataAsyncBinder();
        //JTODO remove conversation from string to data
        NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
        return binder(data);
    };
}
