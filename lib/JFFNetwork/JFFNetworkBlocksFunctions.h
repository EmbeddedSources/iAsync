#ifndef JFF_NETWORK_BLOCKS_FUNCTIONS_INCLUDED
#define JFF_NETWORK_BLOCKS_FUNCTIONS_INCLUDED

#import <JFFNetwork/JNUrlConnectionCallbacks.h>
#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

@class NSURL
, NSData
, NSString
, JFFLocalCookiesStorage
, JFFURLConnectionParams;

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
   , NSData* postData_
   , NSDictionary* headers_ );

JFFAsyncOperation liveDataURLResponseLoader(
   NSURL* url_
   , NSData* postData_
   , NSDictionary* headers_ );

#endif //JFF_NETWORK_BLOCKS_FUNCTIONS_INCLUDED
