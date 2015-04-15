#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@class FBSession;

#ifdef __cplusplus
extern "C" {
#endif
    
    JFFAsyncOperation jffFacebookPublishAccessRequest(FBSession *session, NSArray *permissions);

#ifdef __cplusplus
} /* closing brace for extern "C" */
#endif
