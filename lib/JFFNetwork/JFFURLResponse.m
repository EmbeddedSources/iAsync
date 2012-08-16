#import "JFFURLResponse.h"

#import "JFFUrlResponseLogger.h"

@implementation JFFURLResponse

@dynamic expectedContentLength;

-(long long)expectedContentLength
{
    return [ self->_allHeaderFields[ @"Content-Length" ] longLongValue ];
}

#pragma mark -
#pragma mark NSObject
-(NSString*)description
{
    NSString* custom_ = [ JFFUrlResponseLogger descriptionStringForUrlResponse: self ];
    return [ [ NSString alloc ] initWithFormat: @"%@ \n   %@", [ super description ], custom_ ];
}

@end
