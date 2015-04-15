#import "JFFStoreKitTransactionStateFailedError.h"

@implementation NSError (iTunesStoreError)

- (BOOL)isItunesStoreError
{
    return [@"Cannot connect to iTunes Store" isEqualToString:self.description];
}

@end

@implementation JFFStoreKitTransactionStateFailedError

- (instancetype)init
{
    return [self initWithDescription:NSLocalizedString(@"STORE_KIT_TRANSACTION_STATE_FAILED", nil)];
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    JFFStoreKitTransactionStateFailedError *copy = [super copyWithZone:zone];
    
    if (copy) {
        
        copy->_transaction = _transaction;
    }
    
    return copy;
}

- (NSString *)errorLogDescription
{
    return [[NSString alloc] initWithFormat:@"%@ : %@, domain : %@ code : %ld transaction nativeError : %@ payment : %@",
            [self class],
            [self localizedDescription],
            [self domain],
            (long)[self code],
            _transaction.error,
            _transaction.payment.productIdentifier
            ];
}

- (void)writeErrorWithJFFLogger
{
    if ([_transaction.error isItunesStoreError]) {
        
        [super writeErrorToNSLog];
        return;
    }
    [super writeErrorWithJFFLogger];
}

@end
