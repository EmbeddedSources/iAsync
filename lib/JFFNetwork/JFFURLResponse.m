#import "JFFURLResponse.h"

#import "JFFUrlResponseLogger.h"

@implementation JFFURLResponse

@dynamic expectedContentLength;

- (unsigned long long)expectedContentLength
{
    return [self->_allHeaderFields[@"Content-Length"] unsignedLongLongValue];
}

#pragma mark -
#pragma mark NSObject
-(NSString*)description
{
    NSString *custom = [JFFUrlResponseLogger descriptionStringForUrlResponse:self];
    return [[NSString alloc] initWithFormat:@"%@ \n   %@", [super description], custom];
}

@end
