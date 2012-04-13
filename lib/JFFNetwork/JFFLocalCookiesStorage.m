#import "JFFLocalCookiesStorage.h"

//STODO test
@interface JFFLocalCookiesStorage ()

@property ( nonatomic, retain ) NSMutableSet* allCookies;

@end

//STODO implement
@implementation JFFLocalCookiesStorage

@synthesize allCookies = _allCookies;

-(void)dealloc
{
    [ _allCookies release ];

    [ super dealloc ];
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

-(void)setCookies:( NSArray* )cookies_
{
    for ( NSHTTPCookie* cookie_ in cookies_ )
    {
        [ _allCookies addObject: cookie_ ];
    }
}

-(NSArray*)cookiesForURL:( NSURL* )url_
{
//    NSSet* result_ = [ _allCookies select: ^BOOL( NSHTTPCookie* cookie_ )
//    {
//        return [ cookie_ acceptURL: url_ ];
//    } ];

    return [ _allCookies allObjects ];
}

@end
