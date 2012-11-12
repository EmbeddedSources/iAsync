#import "SKPaymentTransaction+ReceiptInBase64.h"

@implementation SKPaymentTransaction (ReceiptInBase64)

- (NSString *)transactionReceiptBase64
{
    return [NSString base64StringFromData:self.transactionReceipt length:0];
}

@end
