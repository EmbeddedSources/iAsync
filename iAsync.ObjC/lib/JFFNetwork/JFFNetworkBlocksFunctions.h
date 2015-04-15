#ifndef JFF_NETWORK_BLOCKS_FUNCTIONS_INCLUDED
#define JFF_NETWORK_BLOCKS_FUNCTIONS_INCLUDED

#import <JFFNetwork/JNUrlConnectionCallbacks.h>
#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

@class NSURL
, NSData
, NSString
, JFFLocalCookiesStorage
, JFFURLConnectionParams;

#ifdef __cplusplus
extern "C" {
#endif

JFFAsyncOperation genericChunkedURLResponseLoader(JFFURLConnectionParams *params);

JFFAsyncOperation genericDataURLResponseLoader(JFFURLConnectionParams *params);

// Backward compatibility versions
JFFAsyncOperation chunkedURLResponseLoader(NSURL *url,
                                           NSData *postData,
                                           NSDictionary *headers);

JFFAsyncOperation dataURLResponseLoader(NSURL *url,
                                        NSData *postData,
                                        NSDictionary *headers);

JFFAsyncOperation liveChunkedURLResponseLoader(NSURL *url,
                                               NSData *postData,
                                               NSDictionary *headers);

JFFAsyncOperation liveDataURLResponseLoader(NSURL *url,
                                            NSData *postData,
                                            NSDictionary *headers);
    
JFFAsyncOperation perkyDataURLResponseLoader(NSURL *url,
                                             NSData *postData,
                                             NSDictionary *headers);

#ifdef __cplusplus
} /* closing brace for extern "C" */
#endif

#endif //JFF_NETWORK_BLOCKS_FUNCTIONS_INCLUDED
