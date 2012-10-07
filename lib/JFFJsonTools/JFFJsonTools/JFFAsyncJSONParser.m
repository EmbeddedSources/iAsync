#import "JFFAsyncJSONParser.h"

JFFAsyncOperation asyncOperationJsonDataParser(NSData *data)
{
    assert([data isKindOfClass:[NSData class]]);
    
    JFFSyncOperation loadDataBlock = ^id(NSError **outError) {
        NSError *jsonError;
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data
                                                               options:NSJSONReadingAllowFragments
                                                                 error:&jsonError];
        
        if (jsonError) {
            [jsonError setToPointer:outError];
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
