#import "asyncXMLParsers.h"

#import "jRestKitXMLTools.h"

#import <JFFAsyncOperations/JFFAsyncOperationsPredefinedBlocks.h>

//JTODO test
JFFAsyncOperationBinder xmlDocumentWithDataAsyncBinder( void )
{
    return ^JFFAsyncOperation(NSData *data) {
        return ^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler progressCallback,
                                        JFFCancelAsyncOperationHandler cancelCallback,
                                        JFFDidFinishAsyncOperationHandler doneCallback) {
            
            NSError *parseError = nil;
            //STODO parse on separate thread and test
            CXMLDocument *document = xmlDocumentWithData(data, &parseError);
            
            if (doneCallback)
                doneCallback(document, parseError);
            
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
