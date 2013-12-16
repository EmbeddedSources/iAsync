#import <Foundation/Foundation.h>

typedef double(^JFFCurrencyChanger)(double);

@interface NSString (LocalizedPrice)

+ (instancetype)localizedPrice:(NSNumber *)price
                   priceLocale:(NSLocale *)priceLocale;

@end
