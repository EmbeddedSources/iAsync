#import "NSURL+URLWithLocation.h"

static NSString* portComponentStr( NSNumber* port_ )
{
    static NSString* const urlPortFormat_ = @":%@";

    return port_ ? [ [ NSString alloc ] initWithFormat: urlPortFormat_, port_ ] : @"";
}

static NSString* loginAndPasswordComponentStr( NSString* login_, NSString* password_ )
{
    if ( ![ login_ hasSymbols ] )
        return @"";

    if ( ![ password_ hasSymbols ] )
    {
        static NSString* const urlLoginFormat_ = @"%@@";
        return [ [ NSString alloc ] initWithFormat: urlLoginFormat_, login_ ];
    }

    static NSString* const urlLoginPasswordFormat_ = @"%@:%@@";
    return [ [ NSString alloc ] initWithFormat: urlLoginPasswordFormat_, login_, password_ ];
}

@implementation NSURL (URLWithLocation)

-(id)URLWithLocation:( NSString* )location_
{
    NSParameterAssert( [ location_ hasPrefix: @"/" ] );

    static NSString* const urlFormat_ = @"%@://%@%@%@%@";
    NSString* urlString_ = [ [ NSString alloc ] initWithFormat: urlFormat_
                            , self.scheme
                            , loginAndPasswordComponentStr( self.user, self.password )
                            , self.host
                            , portComponentStr( self.port )
                            , location_
                            ];

    NSURL* result_ = [ [ NSURL alloc ] initWithString: urlString_ ];

    return result_;
}

@end
