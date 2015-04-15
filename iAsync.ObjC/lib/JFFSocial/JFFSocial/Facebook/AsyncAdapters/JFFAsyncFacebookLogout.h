#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@class FBSession;

#ifdef __cplusplus
extern "C" {
#endif

    JFFAsyncOperation jffFacebookLogout(FBSession *facebook, BOOL renewSystemAuthorization);

#ifdef __cplusplus
} /* closing brace for extern "C" */
#endif
