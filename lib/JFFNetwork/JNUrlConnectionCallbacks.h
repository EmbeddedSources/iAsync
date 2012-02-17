#ifndef __JN_URL_CONNECTION_CALLBACKS_H__
#define __JN_URL_CONNECTION_CALLBACKS_H__

#import <JFFNetwork/JNUrlResponse.h>

typedef void (^ESDidReceiveResponseHandler)( id/*< JNUrlResponse >*/ response_ );
typedef void (^ESDidFinishLoadingHandler)( NSError* error_ );
typedef void (^ESDidReceiveDataHandler)( NSData* data_ );
typedef BOOL (^ShouldAcceptCertificateForHost)( NSString* host_ );

#endif //__JN_URL_CONNECTION_CALLBACKS_H__

