#import "JFFUrlResponseLogger.h"

@implementation JFFUrlResponseLogger

+ (NSString *)descriptionStringForUrlResponse:(id)urlResponse
{
    NSAssert([urlResponse respondsToSelector:@selector(statusCode           )], @"[!!! ERROR !!!] statusCode not supported"           );
    NSAssert([urlResponse respondsToSelector:@selector(expectedContentLength)], @"[!!! ERROR !!!] expectedContentLength not supported");
    NSAssert([urlResponse respondsToSelector:@selector(allHeaderFields      )], @"[!!! ERROR !!!] allHeaderFields not supported"      );
    
    NSMutableString *result = [[NSMutableString alloc] initWithFormat:@"<<< UrlResponse. HttpStatusCode = %ld \n", (long)[ urlResponse statusCode ] ] ;
    [result appendFormat: @"Result length = %lld \n", [urlResponse expectedContentLength]];
    
    NSString *headerFields = [self dumpHttpHeaderFields:[urlResponse allHeaderFields]];
    [result appendString:headerFields];
    
    return [result copy];
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
