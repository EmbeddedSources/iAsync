#import "JFFTwitterResponseError.h"

@implementation JFFTwitterResponseError

- (instancetype)init
{
    return [self initWithDescription:NSLocalizedString(@"JFF_TWITTER_RESPONSE_ERROR", nil)];
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    JFFTwitterResponseError *result = [super copyWithZone:zone];
    
    if (result) {
        result->_context  = [_context  copyWithZone:zone];
        result->_response = [_response copyWithZone:zone];
    }
    
    return result;
}

- (void)writeErrorWithJFFLogger
{
    [JFFLogger logErrorWithFormat:@"%@ context:%@ response:%@", [self localizedDescription], _context, _response];
}

@end
