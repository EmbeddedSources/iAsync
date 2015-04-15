#import <Foundation/Foundation.h>

#import <StoreKit/SKProduct.h>

@interface SKProduct (LocalizedPriceString)

@property (nonatomic, readonly) NSString *localizedPriceString;

@end
