#import "JFFStoreKitInvalidProductIdentifierError.h"

@implementation JFFStoreKitInvalidProductIdentifierError

- (instancetype)init
{
    return [self initWithDescription:NSLocalizedString(@"STORE_KIT_INVALID_PRODUCT_IDENTIFIER", nil)];
}

- (void)writeErrorWithJFFLogger
{
#ifndef DEBUG
    NSString *str = [[NSString alloc] initWithFormat:@"%@ : %@", [self class], [self errorLogDescription]];
    [[JLogger sharedJLogger] logError:str];
#endif //DEBUG
}

@end
