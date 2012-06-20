#import "BadHeadersMockNetwork.h"

@implementation BadHeadersMockNetwork


+(NSURLRequest*)canonicalRequestForRequest:(NSURLRequest *)request_
{
    return request_;
}

+(BOOL)canInitWithRequest:( NSURLRequest* )request_
{
    return [ request_.URL.absoluteString hasPrefix: @"http://abrakadabra.com" ];
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)aRequest toRequest:(NSURLRequest *)bRequest
{
    return NO;
}

-(void)startLoading
{
    NSURL* url_ = [ NSURL URLWithString: @"http://abrakadabra.com" ];
    NSDictionary* headers_ = [ NSDictionary dictionaryWithObjectsAndKeys:
                              @"close", @"Connection",
                              @"0", @"Content-Length",
                              @"text/html", @"Content-Type",
                              @"Tue, 05 Jun 2012 08:15:16 GMT", @"Date"
                              @"http://abrakadabra.com/?f", @"Location",
                              @"Apache/2.2.17 (Ubuntu)", @"Server"
                              @"WEB=W2; path=/", @"Set-Cookie",
                              @"Accept-Encoding", @"Vary"
                              @"PHP/5.3.5-1ubuntu7.8", @"X-Powered-By"
                              , nil ];
    
    NSHTTPURLResponse* response_ = [ [ NSHTTPURLResponse alloc ] initWithURL: url_
                                                                  statusCode: 302
                                                                 HTTPVersion: @"HTTP/1.1"
                                                                headerFields: headers_  ];
    
    
    [ [ self client ] URLProtocol: self
               didReceiveResponse: response_
               cacheStoragePolicy: NSURLCacheStorageNotAllowed ];



    [ [ self client ] URLProtocolDidFinishLoading: self ];
}

@end
