#import "JFFSocialAsyncUtils.h"

JFFAsyncOperationBinder asyncJsonDataAnalizer()
{
    JFFAsyncOperationBinder parser = ^JFFAsyncOperation(NSData *data)
    {
        assert(data);

        JFFSyncOperation loadDataBlock_ = ^id(NSError **outError)
        {
            NSError *jsonError;
            NSDictionary* result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];

            if (jsonError)
            {
                [jsonError setToPointer:outError];
                return nil;
            }

            return result;
        };
        return asyncOperationWithSyncOperation(loadDataBlock_);
    };

    return parser;
}
