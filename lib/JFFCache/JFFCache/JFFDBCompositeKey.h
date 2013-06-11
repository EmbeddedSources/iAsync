#import <Foundation/Foundation.h>

@interface JFFDBCompositeKey : NSObject 

+ (instancetype)compositeKeyWithKeys:(NSString *)key, ...;
+ (instancetype)compositeKeyWithKey:(JFFDBCompositeKey *)compositeKey forIndexes:(NSIndexSet *)indexes;

- (NSString *)toCompositeKey;

@end

