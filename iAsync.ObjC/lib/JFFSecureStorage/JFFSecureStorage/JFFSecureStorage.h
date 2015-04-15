#import <Foundation/Foundation.h>

//TODO : Use own custom encryption as the one from Apple is exploited

@protocol JFFSecureStorage;

#ifdef __cplusplus
extern "C" {
#endif

    void jffStoreSecureCredentials(NSString *login,
                                   NSString *password,
                                   NSURL *url);
    
    NSString* jffGetSecureCredentialsForURL(NSString **login,
                                            NSURL *url);

#ifdef __cplusplus
} /* closing brace for extern "C" */
#endif
