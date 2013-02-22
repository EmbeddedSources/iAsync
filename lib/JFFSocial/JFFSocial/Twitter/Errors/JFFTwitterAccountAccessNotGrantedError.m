#import "JFFTwitterAccountAccessNotGrantedError.h"

@implementation JFFTwitterAccountAccessNotGrantedError

-(id)init
{
    return [ self initWithDescription: NSLocalizedString( @"ACCESS_TO_TWITTER_ACCOUNTS_NOT_GRANTED", nil ) ];
}

- (void)writeErrorWithJFFLogger
{
}

@end
