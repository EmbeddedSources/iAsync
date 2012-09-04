#import "JNNsUrlConnection.h"

#import "JFFURLConnectionParams.h"
#import "JFFLocalCookiesStorage.h"

#import "NSMutableURLRequest+CreateRequestWithURLParams.h"

#define NSURLConnectionDoesNotWorkWithLocalFiles

@implementation JNNsUrlConnection
{
    NSURLConnection* _nativeConnection;
    JFFURLConnectionParams* _params;
}

-(id)initWithURLConnectionParams:( JFFURLConnectionParams* )params_
{
    NSParameterAssert( params_ );

    self = [ super init ];

    if ( self )
    {
        self->_params = params_;

#ifdef NSURLConnectionDoesNotWorkWithLocalFiles
        if ( ![ self->_params.url isFileURL ] )
#endif
        {
            NSMutableURLRequest* request_ = [ NSMutableURLRequest mutableURLRequestWithParams: params_ ];

            NSURLConnection* nativeConnection_ = [ [ NSURLConnection alloc ] initWithRequest: request_
                                                                                    delegate: self
                                                                            startImmediately: NO ];

            self->_nativeConnection = nativeConnection_;
        }
    }

    return self;
}

#ifdef NSURLConnectionDoesNotWorkWithLocalFiles
-(void)processLocalFileWithPath:( NSString* )path_
{
    NSError* error_;
    //STODO read file in separate thread
    //STODO read big files by chunks
    NSData* data_ = [ [ NSData alloc ] initWithContentsOfFile: path_
                                                      options: 0
                                                        error: &error_ ];
    if ( error_ )
    {
        [ self connection: self->_nativeConnection
         didFailWithError: error_ ];
    }
    else
    {
        NSHTTPURLResponse* response_ =
        [ [ NSHTTPURLResponse alloc ] initWithURL: self->_params.url
                                       statusCode: 200
                                      HTTPVersion: @"HTTP/1.1"
                                     headerFields: nil ];
        [ self connection: self->_nativeConnection
       didReceiveResponse: response_ ];

        [ self connection: self->_nativeConnection
           didReceiveData: data_ ];

        [ self connectionDidFinishLoading: self->_nativeConnection ];
    }
}
#endif

#pragma mark -
#pragma mark JNUrlConnection
-(void)start
{
#ifdef NSURLConnectionDoesNotWorkWithLocalFiles
    if ( [ self->_params.url isFileURL ] )
    {
        NSString* path_ = [ self->_params.url path ];
        [ self processLocalFileWithPath: path_ ];
        return;
    }
#endif
    [ self->_nativeConnection start ];
}

-(void)cancel
{
    [ self clearCallbacks ];
    [ self->_nativeConnection cancel ];
}

#pragma mark -
#pragma mark NSUrlConnectionDelegate
-(BOOL)assertConnectionMismatch:( NSURLConnection* )connection_
{
    BOOL isConnectionMismatch_ = ( connection_ != _nativeConnection );
    if ( isConnectionMismatch_ )
    {
        NSLog( @"JNNsUrlConnection : connection mismatch" );
        NSAssert( NO, @"JNNsUrlConnection : connection mismatch" );
        return NO;
    }

    return YES;
}

-(void)connection:( NSURLConnection* )connection_
didReceiveResponse:( NSHTTPURLResponse* )response_
{
    if ( ![ self assertConnectionMismatch: connection_ ] )
    {
        return;
    }

    if ( nil != self.didReceiveResponseBlock )
    {
        self.didReceiveResponseBlock( response_ );
    }
}

-(void)connection:( NSURLConnection* )connection_
   didReceiveData:( NSData* )chunk_
{
    if ( ![ self assertConnectionMismatch: connection_ ] )
    {
        return;
    }

    if ( nil != self.didReceiveDataBlock )
    {
        self.didReceiveDataBlock( chunk_ );
    }
}

-(void)connectionDidFinishLoading:( NSURLConnection* )connection_
{
    if ( ![ self assertConnectionMismatch: connection_ ] )
    {
        return;
    }

    if ( nil != self.didFinishLoadingBlock )
    {
        self.didFinishLoadingBlock( nil );
    }
    [ self cancel ];
}

-(void)connection:( NSURLConnection* )connection_
 didFailWithError:( NSError* )error_
{
    if ( ![ self assertConnectionMismatch: connection_ ] )
    {
        return;
    }

    if ( nil != self.didFinishLoadingBlock )
    {
        self.didFinishLoadingBlock( error_ );
        [ self cancel ];
    }
}

#pragma mark -
#pragma mark https
-(BOOL)connection:(NSURLConnection *)connection_ 
canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protection_space_ 
{
    return [ protection_space_.authenticationMethod isEqualToString: NSURLAuthenticationMethodServerTrust ];
}

//http://stackoverflow.com/questions/933331/how-to-use-nsurlconnection-to-connect-with-ssl-for-an-untrusted-cert
-(void)connection:( NSURLConnection* )connection_
didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge_ 
{
    NSString* authenticationMethod_ = challenge_.protectionSpace.authenticationMethod;
    BOOL isTrustCheck_ = [ authenticationMethod_ isEqualToString: NSURLAuthenticationMethodServerTrust ];

    if ( isTrustCheck_ )
    {
        BOOL isTrustedHost_ = NO;
        if ( nil != self.shouldAcceptCertificateBlock )
        {
            isTrustedHost_ = self.shouldAcceptCertificateBlock( challenge_.protectionSpace.host );
        }

        if ( isTrustedHost_ )
        {
            NSURLCredential* cred_ = [ NSURLCredential credentialForTrust: challenge_.protectionSpace.serverTrust ];

            [ challenge_.sender useCredential: cred_
                   forAuthenticationChallenge: challenge_ ];
        }
    }

    [ challenge_.sender continueWithoutCredentialForAuthenticationChallenge: challenge_ ];
}

-(NSCachedURLResponse *)connection:(NSURLConnection *)connection
                 willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return nil;
}

@end
