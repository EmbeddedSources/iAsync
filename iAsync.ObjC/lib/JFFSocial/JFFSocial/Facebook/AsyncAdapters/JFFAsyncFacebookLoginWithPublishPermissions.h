#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@class FBSession;

#ifdef __cplusplus
extern "C" {
#endif
    
    JFFAsyncOperation jffFacebookLoginWithPublishPermissions(FBSession *facebook, NSArray *permissions);
    
#ifdef __cplusplus
} /* closing brace for extern "C" */
#endif
