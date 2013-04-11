#import "JFFAsyncJSONParser.h"

#import "JFFParseJsonError.h"

JFFAsyncOperation asyncOperationJsonDataParserWithContext(NSData *data, id<NSCopying> context)
{
    assert([data isKindOfClass:[NSData class]]);
    
    JFFSyncOperation loadDataBlock = ^id(NSError **outError) {
        NSError *jsonError;
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data
                                                               options:NSJSONReadingAllowFragments
                                                                 error:&jsonError];
        
        if (jsonError) {
            if (outError) {
                JFFParseJsonError *error = [JFFParseJsonError new];
                error.nativeError = jsonError;
                error.data        = data;
                error.context     = context;
                *outError = error;
            }
            return nil;
        }
        
        return result;
    };
    
    return asyncOperationWithSyncOperationAndQueue(loadDataBlock, "com.jff.json_tool_library.parse_json");
}

JFFAsyncOperation asyncOperationJsonDataParser(NSData *data)
{
    return asyncOperationJsonDataParserWithContext(data, nil);
}

JFFAsyncOperationBinder asyncOperationBinderJsonDataParser()
{
    return ^JFFAsyncOperation(NSData *data) {
        return asyncOperationJsonDataParser(data);
    };
}
