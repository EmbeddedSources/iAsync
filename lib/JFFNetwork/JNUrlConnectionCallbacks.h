#ifndef __JN_URL_CONNECTION_CALLBACKS_H__
#define __JN_URL_CONNECTION_CALLBACKS_H__

typedef void (^JFFDidReceiveResponseHandler)( id/*< JNUrlResponse >*/ response_ );
typedef void (^JFFDidFinishLoadingHandler)(NSError * error);
typedef void (^JFFDidReceiveDataHandler)(NSData *data);
typedef void (^JFFDidUploadDataHandler)(NSNumber *progress);
typedef BOOL (^JFFShouldAcceptCertificateForHost)(NSString *host);

#endif //__JN_URL_CONNECTION_CALLBACKS_H__
