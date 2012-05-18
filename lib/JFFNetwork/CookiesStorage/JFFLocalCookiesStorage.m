#import "JFFLocalCookiesStorage.h"

#import "NSHTTPCookie+matchesURL.h"

@implementation JFFLocalCookiesStorage
{
    NSMutableSet* _allCookies;
}

-(id)init
{
    self = [ super init ];

    if ( self )
    {
        _allCookies = [ NSMutableSet new ];
    }

    return self;
}

-(void)setCookie:( NSHTTPCookie* )cookie_
{
    [ _allCookies addObject: cookie_ ];
}

-(NSArray*)cookiesForURL:( NSURL* )url_
{
    return [ _allCookies selectArray: ^BOOL( NSHTTPCookie* cookie_ )
    {
        return [ cookie_ matchesURL: url_ ];
    } ];
}

@end
