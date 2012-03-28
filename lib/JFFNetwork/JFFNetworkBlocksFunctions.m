#import "JFFNetworkBlocksFunctions.h"

#import "JNConnectionsFactory.h"
#import "JFFURLConnection.h"

#import <JFFAsyncOperations/AsyncOperartionsBuilder/JFFAsyncOperationBuilder.h>

@implementation JFFURLConnectionParams

@synthesize url                 = _url;
@synthesize httpBody            = _httpBody;
@synthesize httpMethod          = _httpMethod;
@synthesize headers             = _headers;
@synthesize useLiveConnection   = _useLiveConnection; 
@synthesize certificateCallback = _certificateCallback;

-(void)dealloc
{
    [ _url                 release ];
    [ _httpBody            release ];
    [ _httpMethod          release ];
    [ _headers             release ];
    [ _certificateCallback release ];

    [ super dealloc ];
}

@end

@interface JFFAsyncOperationNetwork : NSObject < JFFAsyncOperationInterface >

@property ( nonatomic, retain ) JFFURLConnectionParams* params;
@property ( nonatomic, retain ) id< JNUrlConnection > connection;
@property ( nonatomic, retain ) id resultContext;

@end

@implementation JFFAsyncOperationNetwork

@synthesize params        = _params;
@synthesize connection    = _connection;
@synthesize resultContext = _resultContext;

-(void)dealloc
{
    [ _params        release ];
    [ _connection    release ];
    [ _resultContext release ];

    [ super dealloc ];
}

-(void)asyncOperationWithResultHandler:( void (^)( id, NSError* ) )handler_
                       progressHandler:( void (^)( id ) )progress_
{
    {
        JNConnectionsFactory* factory_ =
        [ [ JNConnectionsFactory alloc ] initWithUrl: self.params.url
                                            httpBody: self.params.httpBody
                                          httpMethod: self.params.httpMethod
                                             headers: self.params.headers ];

        self.connection = self.params.useLiveConnection
            ? [ factory_ createFastConnection     ]
            : [ factory_ createStandardConnection ];

        [ factory_ release ];
    }

    self.connection.shouldAcceptCertificateBlock = self.params.certificateCallback;

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

JFFAsyncOperation genericChunkedURLResponseLoader( JFFURLConnectionParams* params_ )
{
    JFFAsyncOperationNetwork* asyncObj_ = [ [ JFFAsyncOperationNetwork new ] autorelease ];
    asyncObj_.params = params_;
    return buildAsyncOperationWithInterface( asyncObj_ );
}

JFFAsyncOperation genericDataURLResponseLoader( JFFURLConnectionParams* params_ )
{
    return [ [ ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progressCallback_
                                        , JFFCancelAsyncOperationHandler cancelCallback_
                                        , JFFDidFinishAsyncOperationHandler doneCallback_ )
    {
        JFFAsyncOperation loader_ = genericChunkedURLResponseLoader( params_ );

        NSMutableData* responseData_ = [ NSMutableData data ];
        progressCallback_ = [ [ progressCallback_ copy ] autorelease ];
        JFFAsyncOperationProgressHandler dataProgressCallback_ = ^void( id progressInfo_ )
        {
            if ( progressCallback_ )
                progressCallback_( progressInfo_ );
            [ responseData_ appendData: progressInfo_ ];
        };

        if ( doneCallback_ )
        {
            doneCallback_ = [ [ doneCallback_ copy ] autorelease ];
            doneCallback_ = ^void( id result_, NSError* error_ )
            {
                doneCallback_( result_ ? responseData_ : nil, error_ );
            };
        }

        return loader_( dataProgressCallback_, cancelCallback_, doneCallback_ );
    } copy ] autorelease ];
}

#pragma mark -
#pragma mark Compatibility

JFFAsyncOperation chunkedURLResponseLoader( 
   NSURL* url_
   , NSData* postData_
   , NSDictionary* headers_ )
{
    JFFURLConnectionParams* params_ = [ [ JFFURLConnectionParams new ] autorelease ];
    params_.url      = url_;
    params_.httpBody = postData_;
    params_.headers  = headers_;
    return genericChunkedURLResponseLoader( params_ );
}

JFFAsyncOperation dataURLResponseLoader( 
   NSURL* url_
   , NSData* postData_
   , NSDictionary* headers_ )
{
    JFFURLConnectionParams* params_ = [ [ JFFURLConnectionParams new ] autorelease ];
    params_.url      = url_;
    params_.httpBody = postData_;
    params_.headers  = headers_;
    return genericDataURLResponseLoader( params_ );
}

JFFAsyncOperation liveChunkedURLResponseLoader( 
   NSURL* url_
   , NSData* postData_
   , NSDictionary* headers_ )
{
    JFFURLConnectionParams* params_ = [ [ JFFURLConnectionParams new ] autorelease ];
    params_.url      = url_;
    params_.httpBody = postData_;
    params_.headers  = headers_;
    params_.useLiveConnection = YES;
    return genericChunkedURLResponseLoader( params_ );
}

JFFAsyncOperation liveDataURLResponseLoader(
   NSURL* url_
   , NSData* postData_
   , NSDictionary* headers_ )
{
    JFFURLConnectionParams* params_ = [ [ JFFURLConnectionParams new ] autorelease ];
    params_.url      = url_;
    params_.httpBody = postData_;
    params_.headers  = headers_;
    params_.useLiveConnection = YES;
    return genericDataURLResponseLoader( params_ );
}
