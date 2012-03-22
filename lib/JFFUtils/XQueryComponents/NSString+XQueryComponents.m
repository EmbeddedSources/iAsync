#import "NSString+XQueryComponents.h"

@implementation NSString (XQueryComponents)

//JTODO move to separate project
-(NSString*)stringByDecodingURLFormat
{
    return [ self stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding ];
}

-(NSString*)stringByEncodingURLFormat
{
    static NSString* unsafe_ = @" <>#%'\";?:@&=+$/,{}|\\^~[]`-_*!()";
    return (__bridge_transfer NSString*)CFURLCreateStringByAddingPercentEscapes( kCFAllocatorDefault
                                                                                , (__bridge CFStringRef)self
                                                                                , NULL
                                                                                , (__bridge CFStringRef)unsafe_
                                                                                , kCFStringEncodingUTF8 );
}

-(NSDictionary*)dictionaryFromQueryComponents
{
    NSMutableDictionary* query_components_ = [ NSMutableDictionary new ];
    for ( NSString* key_value_pair_string_ in [ self componentsSeparatedByString: @"&" ] )
    {
        NSArray* keyValuePairArray_ = [ key_value_pair_string_ componentsSeparatedByString: @"=" ];

        // Verify that there is at least one key, and at least one value.  Ignore extra = signs
        if ( [ keyValuePairArray_ count ] < 2 )
            continue;

        NSString* key_ = [ [ keyValuePairArray_ objectAtIndex: 0 ] stringByDecodingURLFormat ];
        NSString* value_ = [ [ keyValuePairArray_ objectAtIndex: 1 ] stringByDecodingURLFormat ];
        NSMutableArray* results_ = [ query_components_ objectForKey: key_ ]; // URL spec says that multiple values are allowed per key
        if( !results_ )// First object
        {
            results_ = [ [ NSMutableArray alloc ] initWithCapacity: 1 ];
            [ query_components_ setObject: results_ forKey: key_ ];
        }
        [ results_ addObject: value_ ];
    }
    return [ NSDictionary dictionaryWithDictionary: query_components_ ];
}

@end
