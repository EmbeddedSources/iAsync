#import "JFFParseJsonError.h"

@implementation JFFParseJsonError

- (instancetype)init
{
    return [self initWithDescription:NSLocalizedString(@"PARSE_JSON_ERROR", nil)];
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    JFFParseJsonError *copy = [super copyWithZone:zone];
    
    if (copy) {
        copy->_nativeError = [_nativeError copyWithZone:zone];
        copy->_data        = [_data        copyWithZone:zone];
        copy->_context     = [_context     copyWithZone:zone];
    }
    
    return copy;
}

- (NSString *)errorLogDescription
{
    return [[NSString alloc] initWithFormat:@"%@ context: %@ data: %@",
            [self localizedDescription],
            _context,
            [_data toString]];
}

@end
