#import "JFFURLResponse.h"

#import "JFFUrlResponseLogger.h"

@implementation JFFURLResponse

@dynamic expectedContentLength;

- (unsigned long long)expectedContentLength
{
    id contentLengthObj_ = _allHeaderFields[@"Content-Length"];
    
    SEL ulongSelector_ = @selector(unsignedLongLongValue);
    if ( [ contentLengthObj_ respondsToSelector: ulongSelector_ ] ) {
        return [ contentLengthObj_ unsignedLongLongValue ];
    }

    return (unsigned long long)[ contentLengthObj_ longLongValue ];
}

#pragma mark -
#pragma mark NSObject
- (NSString *)description
{
    NSString *custom = [JFFUrlResponseLogger descriptionStringForUrlResponse:self];
    return [[NSString alloc] initWithFormat:@"%@ \n   %@", [super description], custom];
}

@end
