#import "BadHeadersMockNetwork.h"

@implementation BadHeadersMockNetwork

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    return [request.URL.absoluteString hasPrefix:@"http://abrakadabra.com"];
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)aRequest toRequest:(NSURLRequest *)bRequest
{
    return NO;
}

-(void)startLoading
{
    NSURL *url = [@"http://abrakadabra.com" toURL];
    NSDictionary *headers =
    @{
      @"Connection"     : @"close"                        ,
      @"Content-Length" : @"0"                            ,
      @"Content-Type"   : @"text/html"                    ,
      @"Date"           : @"Tue, 05 Jun 2012 08:15:16 GMT",
      @"Location"       : @"http://abrakadabra.com/?f"    ,
      @"Server"         : @"Apache/2.2.17 (Ubuntu)"       ,
      @"Set-Cookie"     : @"WEB=W2; path=/"               ,
      @"Vary"           : @"Accept-Encoding"              ,
      @"X-Powered-By"   : @"PHP/5.3.5-1ubuntu7.8"         ,
      };
    
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:url
                                                              statusCode:302
                                                             HTTPVersion:@"HTTP/1.1"
                                                            headerFields:headers];
    
    [[self client] URLProtocol:self
            didReceiveResponse:response
            cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    
    [[self client] URLProtocolDidFinishLoading:self];
}

@end
