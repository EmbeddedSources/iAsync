#import "JFFStoreKitInvalidProductIdentifierError.h"

@implementation JFFStoreKitInvalidProductIdentifierError

- (instancetype)init
{
    return [self initWithDescription:NSLocalizedString(@"STORE_KIT_INVALID_PRODUCT_IDENTIFIER", nil)];
}

- (void)writeErrorWithJFFLogger
{
#ifndef DEBUG
    [JFFLogger logErrorWithFormat:@"%@", [self errorLogDescription]];
#endif //DEBUG
}

@end
