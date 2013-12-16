
@interface JFFAsyncJSONParserTests : GHTestCase
@end

@implementation JFFAsyncJSONParserTests

- (void)setUp
{
}

- (void)tearDown
{
}

- (void)testParseEmtyJson
{
    __block id blockResult;
    __block NSError *blockError;
    
    void (^block)(JFFSimpleBlock) = ^void(JFFSimpleBlock block) {
        
        NSData *data = [@"{}" dataUsingEncoding:NSUTF8StringEncoding];
        JFFAsyncOperation loader = asyncOperationJsonDataParser(data);
        
        loader(nil, nil, ^(id result, NSError *error){
            
            blockError  = error;
            blockResult = result;
            block();
        });
    };
    
    performAsyncRequestOnMainThreadWithBlock(block, 10.);
    
    GHAssertNil(blockError, nil);
    GHAssertNotNil(blockResult, nil);
    GHAssertTrue([blockResult isKindOfClass:[NSDictionary class]], nil);
}

@end
