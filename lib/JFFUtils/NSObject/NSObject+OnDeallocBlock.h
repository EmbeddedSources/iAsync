#import <Foundation/Foundation.h>

@interface NSObject (OnDeallocBlock)

- (void)addOnDeallocBlock:(void(^)(void))block;
- (void)removeOnDeallocBlock:(void(^)(void))block;

@end
