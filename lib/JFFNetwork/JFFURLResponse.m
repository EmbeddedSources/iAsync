#import "JFFURLResponse.h"

#import "JFFUrlResponseLogger.h"

@implementation JFFURLResponse

@synthesize statusCode
, allHeaderFields
, url;

@dynamic expectedContentLength;

-(long long)expectedContentLength
{
    return [ [ allHeaderFields objectForKey: @"Content-Length" ] longLongValue ];
}

#pragma mark -
#pragma mark NSObject
-(NSString*)description
{
    NSString* custom_ = [ JFFUrlResponseLogger descriptionStringForUrlResponse: self ];
    return [ NSString stringWithFormat: @"%@ \n   %@", [ super description ], custom_ ];
}

@end
