#import <JFFStoreKit/Errors/JFFStoreKitError.h>

@interface JFFStoreKitTransactionStateFailedError : JFFStoreKitError

@property (nonatomic) NSError *originalError;

@end
