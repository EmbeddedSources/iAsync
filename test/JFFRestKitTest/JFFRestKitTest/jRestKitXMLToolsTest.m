
#import <JFFRestKit/XML/jRestKitXMLTools.h>

@interface jRestKitXMLToolsTest : GHTestCase
@end

@implementation jRestKitXMLToolsTest

-(void)testDocumentOfValidXML
{
    NSString* xml_ = @"<user><item></item><item></item></user>";

    NSData* data_ = [ xml_ dataUsingEncoding: NSUTF8StringEncoding ];

    NSError* error_;

    CXMLDocument* document_ = xmlDocumentWithData( data_, &error_ );

    GHAssertNotNil( document_, @"ok" );
    GHAssertNil( error_, @"ok" );
}

-(void)testDocumentOfInvalidXML
{
    NSString* xml_ = @"<user><item></item><item></user>";

    NSData* data_ = [ xml_ dataUsingEncoding: NSUTF8StringEncoding ];

    NSError* error_;

    CXMLDocument* document_ = xmlDocumentWithData( data_, &error_ );

    GHAssertNil( document_, @"ok" );
    GHAssertNotNil( error_, @"ok" );
}

-(void)testDocumentOfInvalidXMLDoc
{
    NSMutableData* data_ = [ NSMutableData new ];

    char bytes_[] = { 0,0,0,0 };
    [ data_ appendBytes: bytes_ length: sizeof( bytes_ )/sizeof( char ) ];

    NSError* error_;

    CXMLDocument* document_ = xmlDocumentWithData( data_, &error_ );

    GHAssertNil( document_, @"ok" );
    GHAssertNotNil( error_, @"ok" );
}

-(void)testDocumentOfEmptyXML
{
    {
        NSError* error_;
        CXMLDocument* document_ = xmlDocumentWithData( [ NSData new ], &error_ );

        GHAssertNil( document_, @"ok" );
        GHAssertTrue( [ error_ isMemberOfClass: [ JFFRestKitParseEmptyXMLError class ] ], @"ok" );
    }
    {
        NSError* error_;
        CXMLDocument* document_ = xmlDocumentWithData( nil, &error_ );
    
        GHAssertNil( document_, @"ok" );
        GHAssertTrue( [ error_ isMemberOfClass: [ JFFRestKitParseEmptyXMLError class ] ], @"ok" );
    }
}

@end
