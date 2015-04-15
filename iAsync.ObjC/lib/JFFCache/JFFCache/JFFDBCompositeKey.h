#import <Foundation/Foundation.h>

@interface JFFDBCompositeKey : NSObject <NSCopying>

+ (instancetype)compositeKeyWithKeys:(NSString *)key, ... NS_REQUIRES_NIL_TERMINATION;
+ (instancetype)compositeKeyWithKey:(JFFDBCompositeKey *)compositeKey forIndexes:(NSIndexSet *)indexes;

- (NSString *)toCompositeKey;

@end

