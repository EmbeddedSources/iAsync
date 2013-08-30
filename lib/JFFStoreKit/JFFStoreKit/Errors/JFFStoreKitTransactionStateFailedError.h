#import <JFFStoreKit/Errors/JFFStoreKitError.h>

#import <Foundation/Foundation.h>

@interface JFFStoreKitTransactionStateFailedError : JFFStoreKitError

@property (nonatomic) NSError *originalError;

@end
