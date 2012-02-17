#import "JNConnectionsFactory.h"

#import "JFFURLConnection.h"
#import "JNNsUrlConnection.h"

@interface JNConnectionsFactory ()

@property ( nonatomic, retain ) NSURL       * url     ;
@property ( nonatomic, retain ) NSData      * postData;
@property ( nonatomic, retain ) NSDictionary* headers ;

@end

@implementation JNConnectionsFactory

@synthesize url      = _url      ;
@synthesize postData = _post_data;
@synthesize headers  = _headers  ;

-(void)dealloc
{
   [ _url       release ];
   [ _post_data release ];
   [ _headers   release ];
   
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
        postData:( NSData* )post_data_
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

    self.url      = url_      ;
    self.postData = post_data_;
    self.headers  = headers_  ;
   
    return self;
}

#pragma mark -
#pragma mark Factory
-(id< JNUrlConnection >)createFastConnection
{
   return [ JFFURLConnection connectionWithURL: self.url     
                                      postData: self.postData
                                       headers: self.headers ];
}

-(id< JNUrlConnection >)createStandardConnection
{
    static const NSTimeInterval timeout_ = 60.;
    NSMutableURLRequest* request_ = [ NSMutableURLRequest requestWithURL: self.url
                                                             cachePolicy: NSURLRequestReloadIgnoringLocalCacheData 
                                                         timeoutInterval: timeout_ ];

    NSString* http_method_ = self.postData ? @"POST" : @"GET";

    [ request_ setHTTPBody           : self.postData ];
    [ request_ setAllHTTPHeaderFields: self.headers  ];
    [ request_ setHTTPMethod         : http_method_  ];

    JNNsUrlConnection* result_ = [ [ JNNsUrlConnection alloc ] initWithRequest: request_ ];
    return [ result_ autorelease ];
}

@end
