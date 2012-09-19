#import <Foundation/Foundation.h>

@interface NSObject (ProperIsKindOfClass)

+ (BOOL)properIsKindOfClass:(Class)aClass;
- (BOOL)properIsKindOfClass:(Class)aClass;

@end
