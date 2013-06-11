#import "JFFJsonValidationError.h"

@implementation JFFJsonValidationError

- (instancetype)init
{
    return [self initWithDescription:NSLocalizedString(@"JSON_VALIDATION_ERROR", nil)];
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    JFFJsonValidationError *copy = [super copyWithZone:zone];
    
    if (copy) {
        copy->_jsonObject  = [_jsonObject  copyWithZone:zone];
        copy->_jsonPattern = [_jsonPattern copyWithZone:zone];
        copy->_message     = [_message     copyWithZone:zone];
    }
    
    return copy;
}

- (void)writeErrorWithJFFLogger
{
    [JFFLogger logErrorWithFormat:@"%@ jsonObject:%@ jsonPattern:%@ message:%@", [self localizedDescription], _jsonObject, _jsonPattern, _message];
}

@end
