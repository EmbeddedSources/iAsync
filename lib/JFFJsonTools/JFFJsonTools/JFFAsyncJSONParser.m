#import "JFFAsyncJSONParser.h"

#import "JFFParseJsonError.h"

JFFAsyncOperation asyncOperationJsonDataParserWithContext(NSData *data, id context)
{
    assert([data isKindOfClass:[NSData class]]);
    
    JFFSyncOperation loadDataBlock = ^id(NSError **outError) {
        NSError *jsonError;
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data
                                                               options:NSJSONReadingAllowFragments
                                                                 error:&jsonError];
        
        if (jsonError) {
            if (outError) {
                if (context) {
                    [JFFLogger logErrorWithFormat:@"Context: %@ jsonError: '%@'", context, [data toString]];
                } else {
                    [JFFLogger logErrorWithFormat:@"jsonError: '%@'", [data toString]];
                }
                JFFParseJsonError *error = [JFFParseJsonError new];
                error.nativeError = jsonError;
                error.data        = data;
                *outError = error;
            }
            return nil;
        }
        
        return result;
    };
    
    return asyncOperationWithSyncOperation(loadDataBlock);
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
