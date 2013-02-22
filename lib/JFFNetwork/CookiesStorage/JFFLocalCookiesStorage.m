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
    NSArray* result_ = [ _allCookies selectArray: ^BOOL( NSHTTPCookie* cookie_ )
    {
        BOOL result_ = [ cookie_ matchesURL: url_ ];

        result_ &= cookie_.expiresDate == nil
            || [ cookie_.expiresDate compare: [ NSDate new ] ] == NSOrderedDescending;

        return result_;
    } ];

    return result_;
}

@end
