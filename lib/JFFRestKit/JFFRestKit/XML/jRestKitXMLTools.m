#import "jRestKitXMLTools.h"

#import <CXMLElement.h>
#import <CXMLDocument.h>

#import "JFFRestKitError.h"

//JTODO test
CXMLDocument* xmlDocumentWithData( NSData* data_, NSError** outError_ )
{
    if ( [ data_ length ] == 0 )
    {
        if ( outError_ )
            *outError_ = [ JFFRestKitParseEmptyXMLError new ];
        return nil;
    }

    //STODO parse on separate thread and test
    NSError* parseError_ = nil;

    xmlResetLastError();

    CXMLDocument* document_ = [ [ CXMLDocument alloc ] initWithData: data_
                                                            options: 0
                                                              error: &parseError_ ];

    xmlErrorPtr xmlError_ = xmlGetLastError();

    if ( !parseError_ && xmlError_ )
    {
        //JTODO create separate module error
        parseError_ = [ JFFError errorWithDescription: [ NSString stringWithUTF8String: xmlError_->message ] ];
        document_ = nil;
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
