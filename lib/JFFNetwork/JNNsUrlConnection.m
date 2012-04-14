#import "JNNsUrlConnection.h"
#import "JNAbstractConnection+Constructor.h"

#import "JFFURLConnectionParams.h"
#import "JFFLocalCookiesStorage.h"

#import "NSMutableURLRequest+CreateRequestWithURLParams.h"

@interface JNNsUrlConnection ()

//JTODO move to ARC and remove inner properties
@property ( nonatomic, retain ) NSURLConnection* nativeConnection;
@property ( nonatomic, retain ) JFFURLConnectionParams* params;

@end

@implementation JNNsUrlConnection

@synthesize nativeConnection = _nativeConnection;
@synthesize params           = _params;

-(void)dealloc
{
    [ _nativeConnection release ];
    [ _params release ];

    [ super dealloc ];
}

-(id)initWithURLConnectionParams:( JFFURLConnectionParams* )params_
{
#ifndef __clang_analyzer__
    self = [ super privateInit ];
    if ( nil == self )
    {
        return nil;
    }

    {
        self.params = params_;

        NSMutableURLRequest* request_ = [ NSMutableURLRequest mutableURLRequestWithParams: params_ ];

        if ( params_.cookiesStorage )
        {
            request_.HTTPShouldHandleCookies = NO;
            NSArray* cookies_ = [ params_.cookiesStorage cookiesForURL: params_.url ];
            NSDictionary* cookiesheaders_ =
            [ NSHTTPCookie requestHeaderFieldsWithCookies: cookies_ ];
            [ cookiesheaders_ enumerateKeysAndObjectsUsingBlock: ^( id cookieName_
                                                                   , id cookieValue_
                                                                   , BOOL* stop_ )
            {
                [ request_ addValue: cookieValue_ forHTTPHeaderField: cookieName_ ];
            } ];
        }

        //!c self is retained by native_connection_
        //JTODO : break the cycle
        NSURLConnection* nativeConnection_ = [ [ NSURLConnection alloc ] initWithRequest: request_
                                                                                delegate: self
                                                                        startImmediately: NO ];

        self.nativeConnection = nativeConnection_;
        [ nativeConnection_ release ];
    }

    return self;
#else
    return nil;
#endif
}

#pragma mark -
#pragma mark JNUrlConnection
-(void)start
{
    [ self.nativeConnection start ];
}

-(void)cancel
{
    [ self clearCallbacks ];
    [ self.nativeConnection cancel ];
}

#pragma mark -
#pragma mark NSUrlConnectionDelegate
-(BOOL)assertConnectionMismatch:( NSURLConnection* )connection_
{
    BOOL isConnectionMismatch_ = ( connection_ != self.nativeConnection );
    if ( isConnectionMismatch_ )
    {
        //!c TODO : handle this properly
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

    if ( self.params.cookiesStorage )
    {
        NSArray* cookies_ =
        [ NSHTTPCookie cookiesWithResponseHeaderFields: [ response_ allHeaderFields ]
                                                forURL: self.params.url ];
        [ self.params.cookiesStorage setCookies: cookies_ ];
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
        [ self cancel ];
    }
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
