#import "jRestKitXMLTools.h"

#import "JFFRestKitParseEmptyXMLError.h"
#import "JFFRestKitParseInvalidXMLError.h"


CXMLDocument* xmlDocumentWithData( NSData* data_, NSError** outError_ )
{
    if ( [ data_ length ] == 0 )
    {
        [ [ JFFRestKitParseEmptyXMLError new ] setToPointer: outError_ ];
        return nil;
    }

    NSError* parseError_ = nil;

    CXMLDocument* document_ = [ [ CXMLDocument alloc ] initWithData: data_
                                                            options: 0
                                                              error: &parseError_ ];

    xmlErrorPtr xmlError_ = nil;
    if ( document_ )
        xmlError_ = xmlCtxtGetLastError( document_->xmlCtxt );

    if ( !parseError_ && xmlError_ )
    {
        NSString* errorDescription_ = [ [ NSString alloc ] initWithUTF8String: xmlError_->message ];
        parseError_ = [ JFFRestKitParseInvalidXMLError newErrorWithDescription: errorDescription_ ];
        document_   = nil;
    }

    [ parseError_ setToPointer: outError_ ];

    return document_;
}
