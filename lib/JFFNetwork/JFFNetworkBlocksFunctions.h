#ifndef JFF_NETWORK_BLOCKS_FUNCTIONS_INCLUDED
#define JFF_NETWORK_BLOCKS_FUNCTIONS_INCLUDED

#import <JFFNetwork/JNUrlConnectionCallbacks.h>
#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

@class NSURL, NSData, NSString;

JFFAsyncOperation genericChunkedURLResponseLoader(
   NSURL* url_
   , NSData* post_data_
   , NSDictionary* headers_
   , BOOL use_live_connection_ 
   , ShouldAcceptCertificateForHost certificate_callback_);

JFFAsyncOperation genericDataURLResponseLoader( 
   NSURL* url_
   , NSData* post_data_
   , NSDictionary* headers_ 
   , BOOL use_live_connection_
   , ShouldAcceptCertificateForHost certificate_callback_);

// Backward compatibility versions
JFFAsyncOperation chunkedURLResponseLoader( 
   NSURL* url_
   , NSData* post_data_
   , NSDictionary* headers_ );

JFFAsyncOperation dataURLResponseLoader( 
   NSURL* url_
   , NSData* post_data_
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
