#import "JFFStoreKitTransactionStateFailedError.h"

@implementation JFFStoreKitTransactionStateFailedError

- (id)init
{
    return [self initWithDescription:NSLocalizedString(@"STORE_KIT_TRANSACTION_STATE_FAILED", nil)];
}

- (id)copyWithZone:(NSZone *)zone
{
    JFFStoreKitTransactionStateFailedError *copy = [[[self class] allocWithZone:zone] init];
    
    if (copy) {
        
        copy->_originalError = [self->_originalError copyWithZone:zone];
    }
    
    return copy;
}

@end
