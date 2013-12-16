#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, JUncertainLogicStates)
{
    ULFalse = 0,
    ULTrue  = 1,
    ULMaybe = 2
};

@interface NSObject (IsEqualTwoObjects)

+ (BOOL)object:(NSObject *)object1
     isEqualTo:(NSObject *)object2;


+ (JUncertainLogicStates)quickCheckObject:(id)first
                                isEqualTo:(id)second;

+ (BOOL)objcBoolean:(BOOL)first
            xorWith:(BOOL)second;

+ (BOOL)objcBoolean:(BOOL)first
          isEqualTo:(BOOL)second;

@end
