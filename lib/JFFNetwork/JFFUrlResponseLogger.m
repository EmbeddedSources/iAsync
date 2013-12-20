#import "JFFUrlResponseLogger.h"

@implementation JFFUrlResponseLogger

+(NSString*)descriptionStringForUrlResponse:(id)url_response_
{
    NSAssert( [ url_response_ respondsToSelector: @selector( statusCode            ) ], @"[!!! ERROR !!!] statusCode not supported"            );
    NSAssert( [ url_response_ respondsToSelector: @selector( expectedContentLength ) ], @"[!!! ERROR !!!] expectedContentLength not supported" );
    NSAssert( [ url_response_ respondsToSelector: @selector( allHeaderFields       ) ], @"[!!! ERROR !!!] allHeaderFields not supported"       );

    NSString* strStatusCode = [ @( [ url_response_ statusCode ] ) descriptionWithLocale: nil ];
    
    NSMutableString* result_ = [ [ NSMutableString alloc ] initWithFormat: @"<<< UrlResponse. HttpStatusCode = %@ \n", strStatusCode ] ;
    [ result_ appendFormat: @"Result length = %lld \n", [ url_response_ expectedContentLength ] ];

    NSString* headerFields_ = [ self dumpHttpHeaderFields: [ url_response_ allHeaderFields ] ];
    [ result_ appendString: headerFields_ ];

    return [ result_ copy ];
}

+(NSString*)dumpHttpHeaderFields:( NSDictionary* )allHeaderFields_
{   
    NSMutableString* result_ = [ NSMutableString new ];

    [ result_ appendString: @"Headers : \n" ];

    [ allHeaderFields_ enumerateKeysAndObjectsUsingBlock: ^(id key_, id obj_, BOOL* stop_)
    {
        [ result_ appendFormat: @"\t%@ = %@ \n", key_, obj_ ];
    } ];

    return [ result_ copy ];
}

@end
