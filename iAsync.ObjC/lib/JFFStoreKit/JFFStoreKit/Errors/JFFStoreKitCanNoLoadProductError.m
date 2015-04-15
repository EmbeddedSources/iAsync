#import "JFFStoreKitCanNoLoadProductError.h"

@implementation JFFStoreKitCanNoLoadProductError

- (instancetype)init
{
    return [self initWithDescription:NSLocalizedString(@"STORE_KIT_CAN_NOT_LOAD_PRODUCT", nil)];
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    JFFStoreKitCanNoLoadProductError *copy = [super copyWithZone:zone];
    
    if (copy) {
        copy->_productIdentifier = [_productIdentifier copyWithZone:zone];
    }
    
    return copy;
}

- (NSString *)errorLogDescription
{
    return [[NSString alloc] initWithFormat:@"%@ : %@ productIdentifier:%@",
            [self class],
            [self localizedDescription],
            _productIdentifier];
}

- (void)writeErrorWithJFFLogger
{
}

@end
