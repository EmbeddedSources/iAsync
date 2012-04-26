#import <Foundation/Foundation.h>

@interface NSObject (OnDeallocBlock)

-(void)addOnDeallocBlock:( void(^)( void ) )block_;
-(void)removeOnDeallocBlock:( void(^)( void ) )block_;

@end
