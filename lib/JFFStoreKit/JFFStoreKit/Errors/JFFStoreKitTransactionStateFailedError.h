#import <JFFStoreKit/Errors/JFFStoreKitError.h>

@interface JFFStoreKitTransactionStateFailedError : JFFStoreKitError

@property (nonatomic, strong) NSError *originalError;

@end
