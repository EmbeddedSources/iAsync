#import "JFFCacheNoURLError.h"

@implementation JFFCacheNoURLError

- (id)init
{
    return [self initWithDescription:NSLocalizedString(@"JFF_CACHE_NO_URL_ERROR", nil)];
}

- (void)writeErrorWithJFFLogger
{
}

@end
