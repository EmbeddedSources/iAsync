#import "JNConnectionsFactory.h"

#import "JFFURLConnection.h"
#import "JNNsUrlConnection.h"

@interface JNConnectionsFactory ()

//JTODO move to ARC and remove inner properties
@property ( nonatomic, retain ) NSURL       * url       ;
@property ( nonatomic, retain ) NSData      * httpBody  ;
@property ( nonatomic, retain ) NSString    * httpMethod;
@property ( nonatomic, retain ) NSDictionary* headers   ;

@end

@implementation JNConnectionsFactory

@synthesize url        = _url     ;
@synthesize httpBody   = _httpBody;
@synthesize httpMethod = _httpMethod;
@synthesize headers    = _headers ;

-(void)dealloc
{
    [ _url        release ];
    [ _httpBody   release ];
    [ _httpMethod release ];
    [ _headers    release ];

    [ super dealloc ];
}

#pragma mark -
#pragma mark Constructor
-(id)init
{
   [ self doesNotRecognizeSelector: _cmd ];
   [ self release ];   
   return nil;
}

-(id)initWithUrl:( NSURL* ) url_
        httpBody:( NSData* )httpBody_
      httpMethod:( NSString* )httpMethod_
         headers:( NSDictionary* )headers_
{
    if ( nil == url_ )
    {
        NSParameterAssert( url_ );
        [ self release ];

        return nil;
    }

    self = [ super init ];
    if ( nil == self )
    {
        return nil;
    }

    self.url        = url_     ;
    self.httpBody   = httpBody_;
    self.httpMethod = httpMethod_;
    self.headers    = headers_ ;

    return self;
}

#pragma mark -
#pragma mark Factory
-(id< JNUrlConnection >)createFastConnection
{
    return [ JFFURLConnection connectionWithURL: self.url     
                                       httpBody: self.httpBody
                                     httpMethod: self.httpMethod
                                        headers: self.headers ];
}

-(id< JNUrlConnection >)createStandardConnection
{
    static const NSTimeInterval timeout_ = 60.;
    NSMutableURLRequest* request_ = [ NSMutableURLRequest requestWithURL: self.url
                                                             cachePolicy: NSURLRequestReloadIgnoringLocalCacheData 
                                                         timeoutInterval: timeout_ ];

    NSString* httpMethod_ = self.httpMethod ?: @"GET";
    if ( !self.httpMethod && self.httpBody )
    {
        httpMethod_ = @"POST";
    }

    [ request_ setHTTPBody           : self.httpBody ];
    [ request_ setAllHTTPHeaderFields: self.headers  ];
    [ request_ setHTTPMethod         : httpMethod_   ];

    JNNsUrlConnection* result_ = [ [ JNNsUrlConnection alloc ] initWithRequest: request_ ];
    return [ result_ autorelease ];
}

@end
