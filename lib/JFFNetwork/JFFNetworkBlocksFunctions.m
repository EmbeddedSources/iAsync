#import "JFFNetworkBlocksFunctions.h"

#import "JNConnectionsFactory.h"
#import "JFFURLConnection.h"

#import <JFFAsyncOperations/Helpers/JFFCancelAyncOperationBlockHolder.h>

JFFAsyncOperation genericChunkedURLResponseLoader( 
     NSURL* url_
   , NSData* post_data_
   , NSDictionary* headers_ 
   , BOOL use_live_connection_
   , ShouldAcceptCertificateForHost certificate_callback_ )
{
    return [ [ ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progress_callback_
                                        , JFFCancelAsyncOperationHandler cancel_callback_
                                        , JFFDidFinishAsyncOperationHandler done_callback_ )
    {
        JNConnectionsFactory* factory_ = [ [ JNConnectionsFactory alloc ] initWithUrl: url_
                                                                             postData: post_data_
                                                                              headers: headers_ ];
        [ factory_ autorelease ];

        id< JNUrlConnection > connection_ = use_live_connection_ 
                                                ? [ factory_ createFastConnection     ]
                                                : [ factory_ createStandardConnection ];

        connection_.shouldAcceptCertificateBlock = certificate_callback_;

        progress_callback_ = [ [ progress_callback_ copy ] autorelease ];
        connection_.didReceiveDataBlock = ^( NSData* data_ )
        {
            if ( progress_callback_ )
                progress_callback_( data_ );
        };

        __block id result_context_ = nil;

        done_callback_ = [ [ done_callback_ copy ] autorelease ];
        connection_.didFinishLoadingBlock = ^( NSError* error_ )
        {
            if ( done_callback_ )
                done_callback_( error_ ? nil : result_context_, error_ );
        };

        connection_.didReceiveResponseBlock = ^void( id< JNUrlResponse > response_ )
        {
            result_context_ = response_;
        };

        JFFCancelAyncOperationBlockHolder* cancel_callback_block_holder_ = [ [ JFFCancelAyncOperationBlockHolder new ] autorelease ];
        cancel_callback_ = [ [ cancel_callback_ copy ] autorelease ];
        cancel_callback_block_holder_.cancelBlock = [ [ ^void( BOOL canceled_ )
        {
            if ( canceled_ )
                [ connection_ cancel ];

            if ( cancel_callback_ )
                cancel_callback_( canceled_ );
        } copy ] autorelease ];

        [ connection_ start ];

        return cancel_callback_block_holder_.onceCancelBlock;
    } copy ] autorelease ];
}

JFFAsyncOperation genericDataURLResponseLoader( 
     NSURL* url_
   , NSData* post_data_
   , NSDictionary* headers_
   , BOOL use_live_connection_
   , ShouldAcceptCertificateForHost certificate_callback_)
{
   return [ [ ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progress_callback_
                                       , JFFCancelAsyncOperationHandler cancel_callback_
                                       , JFFDidFinishAsyncOperationHandler done_callback_ )
   {
      JFFAsyncOperation loader_ = genericChunkedURLResponseLoader( url_
                                                                  , post_data_
                                                                  , headers_
                                                                  , use_live_connection_
                                                                  , certificate_callback_ );

      NSMutableData* response_data_ = [ NSMutableData data ];
      JFFAsyncOperationProgressHandler data_progress_callback_ = ^void( id progress_info_ )
      {
         [ response_data_ appendData: progress_info_ ];
      };

      if ( done_callback_ )
      {
         done_callback_ = [ [ done_callback_ copy ] autorelease ];
         done_callback_ = ^void( id result_, NSError* error_ )
         {
            done_callback_( result_ ? response_data_ : nil, error_ );
         };
      }

      return loader_( data_progress_callback_, cancel_callback_, done_callback_ );
   } copy ] autorelease ];
}

#pragma mark -
#pragma mark Compatibility

JFFAsyncOperation chunkedURLResponseLoader( 
   NSURL* url_
   , NSData* post_data_
   , NSDictionary* headers_ )
{
   return genericChunkedURLResponseLoader( url_,post_data_, headers_, NO, nil );
}

JFFAsyncOperation dataURLResponseLoader( 
   NSURL* url_
   , NSData* post_data_
   , NSDictionary* headers_ )
{
   return genericDataURLResponseLoader( url_,post_data_, headers_, NO, nil );
}

JFFAsyncOperation liveChunkedURLResponseLoader( 
   NSURL* url_
   , NSData* post_data_
   , NSDictionary* headers_ )
{
   return genericChunkedURLResponseLoader( url_,post_data_, headers_, YES, nil );
}

JFFAsyncOperation liveDataURLResponseLoader(
   NSURL* url_
   , NSData* post_data_
   , NSDictionary* headers_ )
{
   return genericDataURLResponseLoader( url_,post_data_, headers_, YES, nil );
}
