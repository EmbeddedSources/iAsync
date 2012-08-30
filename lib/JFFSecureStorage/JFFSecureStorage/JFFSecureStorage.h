#import <Foundation/Foundation.h>

//TODO : Use own custom encryption as the one from Apple is exploited

@protocol JFFSecureStorage;

#ifdef __cplusplus
extern "C" {
#endif

void jffStoreSecureCredentials( NSString* login_
                               , NSString* password_
                               , NSURL* url_ );

NSString* jffGetSecureCredentialsForURL( NSString** login_
                                        , NSURL* url_ );

#ifdef __cplusplus
} /* closing brace for extern "C" */
#endif
