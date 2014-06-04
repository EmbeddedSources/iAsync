#import "SKProduct+LocalizedPriceString.h"

@implementation SKProduct (LocalizedPriceString)

- (NSString *)localizedPriceString
{
    return [NSString localizedPrice:self.price priceLocale:self.priceLocale];
}

@end
