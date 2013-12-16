#import "JFFLocalCookiesStorage.h"

#import "NSHTTPCookie+matchesURL.h"

@implementation JFFLocalCookiesStorage
{
    NSMutableSet *_allCookies;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _allCookies = [NSMutableSet new];
    }
    
    return self;
}

- (void)setCookie:(NSHTTPCookie *)cookie
{
    NSParameterAssert( [ cookie_ isKindOfClass: [ NSHTTPCookie class ] ] );
    [ self->_allCookies addObject: cookie_ ];
}

-(void)setMultipleCookies:( NSArray* )cookies
{
    for ( NSHTTPCookie* singleCookie in cookies )
    {
        [ self setCookie: singleCookie ];
    }
}

- (NSArray *)cookiesForURL:(NSURL *)url
{
    NSArray *result = [_allCookies selectArray:^BOOL(NSHTTPCookie *cookie) {
        
        BOOL matches = [cookie matchesURL:url];
        
        matches &= cookie.expiresDate == nil
            || [cookie.expiresDate compare:[NSDate new]] == NSOrderedDescending;
        
        return matches;
    }];
    
    return result;
}

@end
