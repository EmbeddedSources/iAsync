#import "NSString+XQueryComponents.h"

@implementation NSString (XQueryComponents)

- (NSString *)stringByDecodingURLFormat
{
    return [self stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)stringByEncodingURLFormat
{
    static NSString *unsafe = @" <>#%'\";?:@&=+$/,{}|\\^~[]`-*!()";
    CFStringRef resultRef = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                    (__bridge CFStringRef)self,
                                                                    NULL,
                                                                    (__bridge CFStringRef)unsafe,
                                                                    kCFStringEncodingUTF8);
    return (__bridge_transfer NSString*)resultRef;
}

- (NSDictionary *)dictionaryFromQueryComponents
{
    NSMutableDictionary *queryComponents = [ NSMutableDictionary new ];
    for (NSString *keyValuePairString in [self componentsSeparatedByString:@"&"])
    {
        NSArray *keyValuePairArray = [keyValuePairString componentsSeparatedByString:@"="];
        
        // Verify that there is at least one key, and at least one value.  Ignore extra = signs
        if ( [ keyValuePairArray count ] < 2 )
            continue;
        
        NSString* key   = [keyValuePairArray[0]stringByDecodingURLFormat];
        NSString* value = [keyValuePairArray[1]stringByDecodingURLFormat];
        NSMutableArray* results_ = queryComponents[ key ]; // URL spec says that multiple values are allowed per key
        // First object
        if( !results_ ) {
            results_ = [[NSMutableArray alloc]initWithCapacity:1];
            queryComponents[key] = results_;
        }
        [results_ addObject: value];
    }
    return [queryComponents copy];
}

@end
