#import "jRestKitXMLTools.h"

#import "JFFRestKitParseEmptyXMLError.h"
#import "JFFRestKitParseInvalidXMLError.h"

CXMLDocument *xmlDocumentWithData(NSData *data, NSError **outError)
{
    if ([data length] == 0) {
        
        if (NULL != outError) {
            *outError = [JFFRestKitParseEmptyXMLError new];
        }
        return nil;
    }
    
    NSError *parseError = nil;
    
    CXMLDocument *document = [[CXMLDocument alloc] initWithData:data
                                                        options:0
                                                          error:&parseError];
    
    xmlErrorPtr xmlError = nil;
    if (document)
        xmlError = xmlCtxtGetLastError(document->xmlCtxt);
    
    if (!parseError && xmlError) {
        
        NSString *errorDescription = @(xmlError->message);
        parseError = [JFFRestKitParseInvalidXMLError newErrorWithDescription:errorDescription];
        document   = nil;
    }
    
    [parseError setToPointer:outError];
    
    return document;
}
