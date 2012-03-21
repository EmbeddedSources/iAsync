#import "JFFNetworkBlocksFunctions.h"

#import "JNConnectionsFactory.h"
#import "JFFURLConnection.h"

#import <JFFAsyncOperations/AsyncOperartionsBuilder/JFFAsyncOperationBuilder.h>

@interface JFFAsyncOperationNetwork : NSObject < JFFAsyncOperationInterface >

@property ( nonatomic, retain ) NSURL* url;
@property ( nonatomic, retain ) NSData* postData;
@property ( nonatomic, retain ) NSDictionary* headers;
@property ( nonatomic, assign ) BOOL useLiveConnection;
@property ( nonatomic, retain ) id< JNUrlConnection > connection;
@property ( nonatomic, copy   ) ShouldAcceptCertificateForHost certificateCallback;

@property ( nonatomic, retain ) id resultContext;

@end

@implementation JFFAsyncOperationNetwork

@synthesize url                 = _url;
@synthesize postData            = _postData;
@synthesize headers             = _headers;
@synthesize useLiveConnection   = _useLiveConnection;
@synthesize connection          = _connection;
@synthesize certificateCallback = _certificateCallback;

@synthesize resultContext = _resultContext;

-(void)dealloc
{
    [ _url                 release ];
    [ _postData            release ];
    [ _headers             release ];
    [ _connection          release ];
    [ _certificateCallback release ];

    [ _resultContext release ];

    [ super dealloc ];
}

-(void)asyncOperationWithResultHandler:( void (^)( id, NSError* ) )handler_
                       progressHandler:( void (^)( id ) )progress_
{
    {
        JNConnectionsFactory* factory_ = [ [ JNConnectionsFactory alloc ] initWithUrl: self.url
                                                                             postData: self.postData
                                                                              headers: self.headers ];

        self.connection = self.useLiveConnection
            ? [ factory_ createFastConnection     ]
            : [ factory_ createStandardConnection ];

        [ factory_ release ];
    }

    self.connection.shouldAcceptCertificateBlock = self.certificateCallback;

    [ self.connection start ];

    __unsafe_unretained typeof(self) self_ = self;

    progress_ = [ [ progress_ copy ] autorelease ];
    self.connection.didReceiveDataBlock = ^( NSData* data_ )
    {
        if ( progress_ )
            progress_( data_ );
    };

    handler_ = [ [ handler_ copy ] autorelease ];
    self.connection.didFinishLoadingBlock = ^( NSError* error_ )
    {
        if ( handler_ )
            handler_( error_ ? nil : self_.resultContext, error_ );
    };

    self.connection.didReceiveResponseBlock = ^void( id< JNUrlResponse > response_ )
    {
        self_.resultContext = response_;
    };
}

-(void)cancel:( BOOL )canceled_
{
    if ( canceled_ )
    {
        [ self.connection cancel ];
        self.connection = nil;
    }
}

@end

JFFAsyncOperation genericChunkedURLResponseLoader( 
     NSURL* url_
   , NSData* postData_
   , NSDictionary* headers_ 
   , BOOL useLiveConnection_
   , ShouldAcceptCertificateForHost certificateCallback_ )
{
    JFFAsyncOperationNetwork* asyncObj_ = [ [ JFFAsyncOperationNetwork new ] autorelease ];
    asyncObj_.url               = url_;
    asyncObj_.postData          = postData_;
    asyncObj_.headers           = headers_;
    asyncObj_.useLiveConnection = useLiveConnection_;

    return buildAsyncOperationWithInterface( asyncObj_ );
}

JFFAsyncOperation genericDataURLResponseLoader( 
     NSURL* url_
   , NSData* post_data_
   , NSDictionary* headers_
   , BOOL use_live_connection_
   , ShouldAcceptCertificateForHost certificate_callback_)
{
    return [ [ ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progressCallback_
                                        , JFFCancelAsyncOperationHandler cancelCallback_
                                        , JFFDidFinishAsyncOperationHandler doneCallback_ )
    {
        //JTODO progressCallback_ do not used
        JFFAsyncOperation loader_ = genericChunkedURLResponseLoader( url_
                                                                    , post_data_
                                                                    , headers_
                                                                    , use_live_connection_
                                                                    , certificate_callback_ );

        NSMutableData* response_data_ = [ NSMutableData data ];
        JFFAsyncOperationProgressHandler dataProgressCallback_ = ^void( id progressInfo_ )
        {
            [ response_data_ appendData: progressInfo_ ];
        };

        if ( doneCallback_ )
        {
            doneCallback_ = [ [ doneCallback_ copy ] autorelease ];
            doneCallback_ = ^void( id result_, NSError* error_ )
            {
                doneCallback_( result_ ? response_data_ : nil, error_ );
            };
        }

        return loader_( dataProgressCallback_, cancelCallback_, doneCallback_ );
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
