#ifndef JFF_NETWORK_BLOCKS_FUNCTIONS_INCLUDED
#define JFF_NETWORK_BLOCKS_FUNCTIONS_INCLUDED

#import <JFFNetwork/JNUrlConnectionCallbacks.h>
#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

@class NSURL, NSData, NSString;

@interface JFFURLConnectionParams : NSObject

@property ( nonatomic, strong ) NSURL* url;
@property ( nonatomic, strong ) NSData* httpBody;
@property ( nonatomic, strong ) NSString* httpMethod;
@property ( nonatomic, strong ) NSDictionary* headers;
@property ( nonatomic, assign ) BOOL useLiveConnection; 
@property ( nonatomic, copy   ) JFFShouldAcceptCertificateForHost certificateCallback;

@end

JFFAsyncOperation genericChunkedURLResponseLoader( JFFURLConnectionParams* params_ );

JFFAsyncOperation genericDataURLResponseLoader( JFFURLConnectionParams* params_ );

// Backward compatibility versions
JFFAsyncOperation chunkedURLResponseLoader( 
   NSURL* url_
   , NSData* postData_
   , NSDictionary* headers_ );

JFFAsyncOperation dataURLResponseLoader( 
   NSURL* url_
   , NSData* postData_
   , NSDictionary* headers_ );

JFFAsyncOperation liveChunkedURLResponseLoader( 
                                           NSURL* url_
                                           , NSData* post_data_
                                           , NSDictionary* headers_ );

JFFAsyncOperation liveDataURLResponseLoader(
                                        NSURL* url_
                                        , NSData* post_data_
                                        , NSDictionary* headers_ );

#endif //JFF_NETWORK_BLOCKS_FUNCTIONS_INCLUDED
