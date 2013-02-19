#import "JFFParseJsonError.h"

@implementation JFFParseJsonError

- (id)init
{
    return [self initWithDescription:NSLocalizedString(@"PARSE_JSON_ERROR", nil)];
}

- (id)copyWithZone:(NSZone *)zone
{
    JFFParseJsonError *copy = [super copyWithZone:zone];
    
    if (copy) {
        copy->_nativeError = [_nativeError copyWithZone:zone];
        copy->_data        = [_data        copyWithZone:zone];
        copy->_context     = [_context     copyWithZone:zone];
    }
    
    return copy;
}

- (void)writeErrorWithJFFLogger
{
    [JFFLogger logErrorWithFormat:@"%@ context: %@ data: %@", [self localizedDescription], _context, [_data toString]];
}

@end
