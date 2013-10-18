#import "JFFStoreKitDisabledError.h"

@implementation JFFStoreKitDisabledError

- (instancetype)init
{
    return [self initWithDescription:NSLocalizedString(@"JFFSTOREKIT_PURCHASE_DISABLED_ERROR", nil)];
}

- (void)writeErrorWithJFFLogger
{
}

@end
