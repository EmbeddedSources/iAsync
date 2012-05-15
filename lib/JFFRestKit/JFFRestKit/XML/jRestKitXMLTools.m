#import "jRestKitXMLTools.h"

#import <CXMLElement.h>
#import <CXMLDocument.h>

#import "JFFRestKitError.h"

CXMLDocument* xmlDocumentWithData( NSData* data_, NSError** outError_ )
{
    if ( [ data_ length ] == 0 )
    {
        if ( outError_ )
            *outError_ = [ JFFRestKitParseEmptyXMLError new ];
        return nil;
    }

    NSError* parseError_ = nil;

    CXMLDocument* document_ = [ [ CXMLDocument alloc ] initWithData: data_
                                                            options: 0
                                                              error: &parseError_ ];

    xmlErrorPtr xmlError_ = xmlCtxtGetLastError( document_->xmlCtxt );

    if ( !parseError_ && xmlError_ )
    {
        NSString* errorDescription_ = [ [ NSString alloc ] initWithUTF8String: xmlError_->message ];
        parseError_ = [ JFFRestKitParseInvalidXMLError errorWithDescription: errorDescription_ ];
        document_   = nil;
    }

    [ parseError_ setToPointer: outError_ ];

    return document_;
}

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
