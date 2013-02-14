#import "JFFJsonValidationError.h"

@implementation JFFJsonValidationError

- (id)init
{
    return [self initWithDescription:NSLocalizedString(@"JSON_VALIDATION_ERROR", nil)];
}

- (id)copyWithZone:(NSZone *)zone
{
    JFFJsonValidationError *copy = [[[self class] allocWithZone:zone] init];
    
    if (copy) {
        copy->_jsonObject  = [self->_jsonObject  copyWithZone:zone];
        copy->_jsonPattern = [self->_jsonPattern copyWithZone:zone];
        copy->_message     = [self->_message     copyWithZone:zone];
    }
    
    return copy;
}

- (void)writeErrorWithJFFLogger
{
    [JFFLogger logErrorWithFormat:@"%@ jsonObject:%@ jsonPattern:%@ message:%@", [self localizedDescription], _jsonObject, _jsonPattern, _message];
}

@end
