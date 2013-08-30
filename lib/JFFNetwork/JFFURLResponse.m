#import "JFFURLResponse.h"

#import "JFFUrlResponseLogger.h"

@implementation JFFURLResponse

@dynamic expectedContentLength;
@dynamic contentEncoding;

- (unsigned long long)expectedContentLength
{
    id contentLengthObj = _allHeaderFields[@"Content-Length"];
    
    SEL ulongSelector = @selector(unsignedLongLongValue);
    if ([contentLengthObj respondsToSelector:ulongSelector]) {
        return [contentLengthObj unsignedLongLongValue];
    }
    
    return (unsigned long long)[contentLengthObj longLongValue];
}

#pragma mark -
#pragma mark NSObject
- (NSString *)description
{
    NSString *custom = [JFFUrlResponseLogger descriptionStringForUrlResponse:self];
    return [[NSString alloc] initWithFormat:@"%@ \n   %@", [super description], custom];
}

- (NSString *)contentEncoding
{
    return _allHeaderFields[@"Content-Encoding"];
}

@end
