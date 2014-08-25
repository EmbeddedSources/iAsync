#import "NSString+LocalizedPrice.h"

@implementation NSString (LocalizedPrice)

+ (instancetype)localizedPrice:(NSNumber *)price
                   priceLocale:(NSLocale *)priceLocale
{
    NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:priceLocale];
    NSString *result = [numberFormatter stringFromNumber:price];
    return result;
}

@end
