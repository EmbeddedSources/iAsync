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
    NSString* strStatusCode = [ @(self.code) descriptionWithLocale: nil ];
    
    [JFFLogger logErrorWithFormat:@"%@ Http code:%@ cantext:%@", [self localizedDescription], strStatusCode, _context];
}

-(BOOL)isHttpNotChangedError
{
    return ( self.code == 304 );
}

-(BOOL)isServiceUnavailableError
{
    return ( self.code == 503 );
}

-(BOOL)isInternalServerError
{
    return ( self.code == 500 );
}

-(BOOL)isNotFoundError
{
    return ( self.code == 404 );
}

@end
