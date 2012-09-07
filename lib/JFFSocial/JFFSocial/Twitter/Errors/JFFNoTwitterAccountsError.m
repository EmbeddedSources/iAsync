#import "JFFNoTwitterAccountsError.h"

@implementation JFFNoTwitterAccountsError

-(id)init
{
    return [ self initWithDescription: NSLocalizedString( @"NO_TWITTER_ACCOUNTS_ERROR", nil ) ];
}

@end
