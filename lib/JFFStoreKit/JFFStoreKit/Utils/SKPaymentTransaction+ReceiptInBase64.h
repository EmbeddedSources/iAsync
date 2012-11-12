#import <StoreKit/StoreKit.h>

@interface SKPaymentTransaction (ReceiptInBase64)

- (NSString *)transactionReceiptBase64;

@end
