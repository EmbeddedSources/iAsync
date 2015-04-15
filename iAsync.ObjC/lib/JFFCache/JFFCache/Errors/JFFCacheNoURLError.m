#import "JFFCacheNoURLError.h"

@implementation JFFCacheNoURLError

- (instancetype)init
{
    return [self initWithDescription:NSLocalizedString(@"JFF_CACHE_NO_URL_ERROR", nil)];
}

- (void)writeErrorWithJFFLogger
{
}

@end
