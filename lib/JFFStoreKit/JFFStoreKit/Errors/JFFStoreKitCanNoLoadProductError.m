#import "JFFStoreKitCanNoLoadProductError.h"

@implementation JFFStoreKitCanNoLoadProductError

- (id)init
{
    return [self initWithDescription:NSLocalizedString(@"STORE_KIT_CAN_NOT_LOAD_PRODUCT", nil)];
}

- (id)copyWithZone:(NSZone *)zone
{
    JFFStoreKitCanNoLoadProductError *copy = [[[self class] allocWithZone:zone] init];
    
    if (copy) {
        copy->_productIdentifier = [self->_productIdentifier copyWithZone:zone];
    }
    
    return copy;
}

@end
