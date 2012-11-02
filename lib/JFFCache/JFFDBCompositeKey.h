#import <Foundation/Foundation.h>

@interface JFFDBCompositeKey : NSObject 

+ (id)compositeKeyWithKeys:(NSString *)key, ...;
+ (id)compositeKeyWithKey:(JFFDBCompositeKey *)compositeKey forIndexes:(NSIndexSet *)indexes;

- (NSString *)toCompositeKey;

@end

