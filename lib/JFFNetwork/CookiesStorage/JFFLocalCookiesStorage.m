#import "JFFLocalCookiesStorage.h"

#import "NSHTTPCookie+matchesURL.h"

@implementation JFFLocalCookiesStorage
{
    NSMutableSet *_allCookies;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        _allCookies = [NSMutableSet new];
    }
    
    return self;
}

- (void)setCookie:(NSHTTPCookie *)cookie
{
    [_allCookies addObject:cookie];
}

- (NSArray *)cookiesForURL:(NSURL *)url
{
    NSArray *result = [_allCookies selectArray:^BOOL(NSHTTPCookie *cookie)
    {
        BOOL result = [cookie matchesURL:url];
        
        result &= cookie.expiresDate == nil
            || [cookie.expiresDate compare:[NSDate new]] == NSOrderedDescending;
        
        return result;
    }];
    
    return result;
}

@end
