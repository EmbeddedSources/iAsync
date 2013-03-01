#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@class FBSession;

#ifdef __cplusplus
extern "C" {
#endif

    JFFAsyncOperation jffRequestFacebookDialog(FBSession *session,
                                               NSDictionary *parameters,
                                               NSString *message,
                                               NSString *title);

#ifdef __cplusplus
} /* closing brace for extern "C" */
#endif
