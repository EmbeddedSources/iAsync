#import "SKProduct+LocalizedPriceString.h"

@implementation SKProduct (LocalizedPriceString)

-(NSString *)localizedPriceString
{
    NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:self.priceLocale];
    NSString *result = [numberFormatter stringFromNumber:self.price];
    return result;
}

@end
