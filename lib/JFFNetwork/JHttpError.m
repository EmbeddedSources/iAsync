#import "JHttpError.h"

@implementation JHttpError

- (id)initWithDescription:(NSString *)description
                     code:(NSInteger)code
{
    return [self initWithDescription:description
                              domain:@"com.just_for_fun.library.http"
                                code:code];
}

- (id)initWithHttpCode:(CFIndex)statusCode
{
    return [self initWithDescription:NSLocalizedString(@"JFF_HTTP_ERROR", nil)
                                code:statusCode];
}

- (id)copyWithZone:(NSZone *)zone
{
    JHttpError *copy = [super copyWithZone:zone];
    
    if (copy) {
        copy->_context = [_context copyWithZone:zone];
    }
    
    return copy;
}

- (void)writeErrorWithJFFLogger
{
    [JFFLogger logErrorWithFormat:@"%@ Http code:%d cantext:%@", [self localizedDescription], self.code, _context];
}

@end
