#import "JFFStoreKitTransactionStateFailedError.h"

@implementation JFFStoreKitTransactionStateFailedError

- (id)init
{
    return [self initWithDescription:NSLocalizedString(@"STORE_KIT_TRANSACTION_STATE_FAILED", nil)];
}

@end
