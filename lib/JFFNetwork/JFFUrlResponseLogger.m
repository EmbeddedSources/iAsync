#import "JFFUrlResponseLogger.h"

@implementation JFFUrlResponseLogger

+ (NSString *)descriptionStringForUrlResponse:(id)url_response_
{
    NSAssert([url_response_ respondsToSelector: @selector( statusCode            ) ], @"[!!! ERROR !!!] statusCode not supported"            );
    NSAssert([url_response_ respondsToSelector: @selector( expectedContentLength ) ], @"[!!! ERROR !!!] expectedContentLength not supported" );
    NSAssert([url_response_ respondsToSelector: @selector( allHeaderFields       ) ], @"[!!! ERROR !!!] allHeaderFields not supported"       );
    
    NSMutableString* result_ = [ [ NSMutableString alloc ] initWithFormat: @"<<< UrlResponse. HttpStatusCode = %d \n", [ url_response_ statusCode ] ] ;
    [ result_ appendFormat: @"Result length = %lld \n", [ url_response_ expectedContentLength ] ];

    NSString* headerFields_ = [ self dumpHttpHeaderFields: [ url_response_ allHeaderFields ] ];
    [ result_ appendString: headerFields_ ];

    return [ result_ copy ];
}

+ (NSString *)dumpHttpHeaderFields:(NSDictionary *)allHeaderFields
{   
    NSMutableString *result = [NSMutableString new];
    
    [result appendString:@"Headers : \n"];
    
    [allHeaderFields enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [result appendFormat:@"\t%@ = %@ \n", key, obj];
    }];
    
    return [result copy];
}

@end
