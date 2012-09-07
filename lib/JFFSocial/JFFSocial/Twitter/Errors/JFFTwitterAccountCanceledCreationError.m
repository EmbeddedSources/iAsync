#import "JFFTwitterAccountCanceledCreationError.h"

@implementation JFFTwitterAccountCanceledCreationError

-(id)init
{
    return [ self initWithDescription: NSLocalizedString( @"USER_HAS_CANCELED_CREATION_OF_TWITTER_ACCOUNT", nil ) ];
}

@end
