#import "JFFLocalCookiesStorage.h"

#import "NSHTTPCookie+matchesURL.h"

//JTODO store in file system
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
//STODO uncomment !!!!
//    NSArray* result_ = [ _allCookies selectArray: ^BOOL( NSHTTPCookie* cookie_ )
//    {
//        return [ cookie_ matchesURL: url_ ];
//    } ];

    return [ _allCookies allObjects ];
}

@end
