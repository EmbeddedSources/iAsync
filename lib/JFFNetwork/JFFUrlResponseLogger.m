#import "JFFUrlResponseLogger.h"

@implementation JFFUrlResponseLogger

+(NSString*)descriptionStringForUrlResponse:(id)url_response_
{
    NSAssert( [ url_response_ respondsToSelector: @selector( statusCode            ) ], @"[!!! ERROR !!!] statusCode not supported"            );
    NSAssert( [ url_response_ respondsToSelector: @selector( expectedContentLength ) ], @"[!!! ERROR !!!] expectedContentLength not supported" );
    NSAssert( [ url_response_ respondsToSelector: @selector( allHeaderFields       ) ], @"[!!! ERROR !!!] allHeaderFields not supported"       );

    NSMutableString* result_ = [ NSMutableString stringWithFormat: @"<<< UrlResponse. HttpStatusCode = %d \n", [ url_response_ statusCode ] ] ;
    [ result_ appendFormat: @"Result length = %lld \n", [ url_response_ expectedContentLength ] ];

    NSString* header_fields_ = [ self dumpHttpHeaderFields: [ url_response_ allHeaderFields ] ];
    [ result_ appendString: header_fields_ ];

    return result_;
}

+(NSString*)dumpHttpHeaderFields:( NSDictionary* )allHeaderFields_
{   
    NSMutableString* result_ = [ NSMutableString new ];

    [ result_ appendString: @"Headers : \n" ];

    [ allHeaderFields_ enumerateKeysAndObjectsUsingBlock: ^(id key_, id obj_, BOOL* stop_)
    {
        [ result_ appendFormat: @"\t%@ = %@ \n", key_, obj_ ];
    } ];

   return result_;
}

@end
