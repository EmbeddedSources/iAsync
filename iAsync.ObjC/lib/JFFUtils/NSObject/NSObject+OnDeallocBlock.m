#import "NSObject+OnDeallocBlock.h"

#import "NSObject+Ownerships.h"
#import "JFFOnDeallocBlockOwner.h"

@implementation JFFOnDeallocBlockOwner (OnDeallocBlockPrivate)

- (BOOL)cantainsOnDeallocBlock:(void(^)(void))block
{
    return self.block == block;
}

@end

@implementation NSObject (OnDeallocBlock)

- (void)addOnDeallocBlock:(void(^)(void))block
{
    JFFOnDeallocBlockOwner *owner = [[JFFOnDeallocBlockOwner alloc] initWithBlock:block];
    [self addOwnedObject:owner];
}

- (void)removeOnDeallocBlock:(void(^)(void))block
{
    @autoreleasepool {
        JFFOnDeallocBlockOwner *objectToRemove = [self firstOwnedObjectMatch:^BOOL(void(^object)(void)) {
            if ([object isKindOfClass:[JFFOnDeallocBlockOwner class]])
                 return [object cantainsOnDeallocBlock:block];
            return NO;
        }];
        
        if (objectToRemove) {
            objectToRemove.block = nil;
            [self removeOwnedObject:objectToRemove];
        }
    }
}

@end
