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
    CFStringRef resultRef_ = CFURLCreateStringByAddingPercentEscapes( kCFAllocatorDefault
                                                                     , (__bridge CFStringRef)self
                                                                     , NULL
                                                                     , (__bridge CFStringRef)unsafe_
                                                                     , kCFStringEncodingUTF8 );
    return (__bridge_transfer NSString*)resultRef_;
}

-(NSDictionary*)dictionaryFromQueryComponents
{
    NSMutableDictionary* queryComponents_ = [ NSMutableDictionary new ];
    for ( NSString* keyValuePairString_ in [ self componentsSeparatedByString: @"&" ] )
    {
        NSArray* keyValuePairArray_ = [ keyValuePairString_ componentsSeparatedByString: @"=" ];

        // Verify that there is at least one key, and at least one value.  Ignore extra = signs
        if ( [ keyValuePairArray_ count ] < 2 )
            continue;

        NSString* key_ = [ [ keyValuePairArray_ objectAtIndex: 0 ] stringByDecodingURLFormat ];
        NSString* value_ = [ [ keyValuePairArray_ objectAtIndex: 1 ] stringByDecodingURLFormat ];
        NSMutableArray* results_ = [ queryComponents_ objectForKey: key_ ]; // URL spec says that multiple values are allowed per key
        if( !results_ )// First object
        {
            results_ = [ [ NSMutableArray alloc ] initWithCapacity: 1 ];
            [ queryComponents_ setObject: results_ forKey: key_ ];
        }
        [ results_ addObject: value_ ];
    }
    return [ [ NSDictionary alloc ] initWithDictionary: queryComponents_ ];
}

@end
