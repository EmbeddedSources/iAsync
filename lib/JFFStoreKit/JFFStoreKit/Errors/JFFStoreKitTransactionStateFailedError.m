#import "JFFStoreKitTransactionStateFailedError.h"

@implementation JFFStoreKitTransactionStateFailedError

- (id)init
{
    return [self initWithDescription:NSLocalizedString(@"STORE_KIT_TRANSACTION_STATE_FAILED", nil)];
}

- (id)copyWithZone:(NSZone *)zone
{
    JFFStoreKitTransactionStateFailedError *copy = [super copyWithZone:zone];
    
    if (copy) {
        
        copy->_originalError = [_originalError copyWithZone:zone];
    }
    
    return copy;
}

- (void)writeErrorWithJFFLogger
{
}

@end
