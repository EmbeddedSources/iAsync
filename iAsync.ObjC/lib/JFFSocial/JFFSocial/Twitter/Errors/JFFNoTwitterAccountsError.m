#import "JFFNoTwitterAccountsError.h"

@implementation JFFNoTwitterAccountsError

- (instancetype)init
{
    return [self initWithDescription:NSLocalizedString(@"NO_TWITTER_ACCOUNTS_ERROR", nil)];
}

- (void)writeErrorWithJFFLogger
{
}

@end
