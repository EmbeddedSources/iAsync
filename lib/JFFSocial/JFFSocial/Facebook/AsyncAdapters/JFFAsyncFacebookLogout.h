#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@class FBSession;

#ifdef __cplusplus
extern "C" {
#endif

    JFFAsyncOperation jffFacebookLogout(FBSession *facebook);

#ifdef __cplusplus
} /* closing brace for extern "C" */
#endif
