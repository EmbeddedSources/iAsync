#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif

    JFFAsyncOperation asyncOperationJsonDataParser(NSData *data);
    JFFAsyncOperationBinder asyncOperationBinderJsonDataParser();

#ifdef __cplusplus
} /* closing brace for extern "C" */
#endif
