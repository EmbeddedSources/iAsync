#import "JFFCacheLoadImageError.h"

@implementation JFFCacheLoadImageError

- (instancetype)init
{
    return [self initWithDescription:NSLocalizedString(@"JFF_CACHE_LOAD_IMAGE_ERROR", nil)];
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    JFFCacheLoadImageError *copy = [super copyWithZone:zone];
    
    if (copy) {
        copy->_nativeError = [_nativeError copyWithZone:zone];
    }
    
    return copy;
}

- (NSString *)errorLogDescription
{
    return [[NSString alloc] initWithFormat:@"%@ : %@, domain : %@ code : %ld nativeError: %@",
            [self class],
            [self localizedDescription],
            [self domain],
            (long)[self code],
            [_nativeError errorLogDescription]];
}

- (void)writeErrorWithJFFLogger
{
    [[JLogger sharedJLogger] logError:[self errorLogDescription]];
}

@end
