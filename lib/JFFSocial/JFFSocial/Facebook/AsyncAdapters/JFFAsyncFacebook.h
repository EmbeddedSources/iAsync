#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@class FBSession;

#ifdef __cplusplus
extern "C" {
#endif
    
    JFFAsyncOperation jffGenericFacebookGraphRequestLoader(FBSession *facebook,
                                                           NSString *graphPath,
                                                           NSString *HTTPMethod,
                                                           NSDictionary *parameters);
    
    JFFAsyncOperation jffFacebookGraphRequestLoader(FBSession *facebook, NSString *graphPath);

#ifdef __cplusplus
} /* closing brace for extern "C" */
#endif
