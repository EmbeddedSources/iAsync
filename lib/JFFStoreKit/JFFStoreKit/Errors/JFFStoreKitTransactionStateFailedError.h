#import <JFFStoreKit/Errors/JFFStoreKitError.h>

#import <Foundation/Foundation.h>

@class SKPaymentTransaction;

@interface JFFStoreKitTransactionStateFailedError : JFFStoreKitError

@property (nonatomic) SKPaymentTransaction *transaction;

@end
