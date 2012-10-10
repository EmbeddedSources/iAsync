#import "JFFAsyncJSONParser.h"

#import "JFFParseJsonError.h"

JFFAsyncOperation asyncOperationJsonDataParser(NSData *data)
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
                *outError = error;
            }
            return nil;
        }
        
        return result;
    };
    
    return asyncOperationWithSyncOperation(loadDataBlock);
}

JFFAsyncOperationBinder asyncOperationBinderJsonDataParser()
{
    return ^JFFAsyncOperation(NSData *data) {
        return asyncOperationJsonDataParser(data);
    };
}
