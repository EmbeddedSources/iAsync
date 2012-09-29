#import "NSObject+ProperIsKindOfClass.h"

@implementation NSArray (ProperIsKindOfClass)

+ (BOOL)properIsKindOfClassIsNSArray
{
    return YES;
}

@end

@implementation NSDictionary (ProperIsKindOfClass)

+ (BOOL)properIsKindOfClassIsNSDictionary
{
    return YES;
}

@end

@implementation NSObject (ProperIsKindOfClass)

+ (BOOL)properIsKindOfClassIsNSArray
{
    return NO;
}

+ (BOOL)properIsKindOfClassIsNSDictionary
{
    return NO;
}

+ (BOOL)fixedForLiteralClassesIsSubclassOfClass:(Class)aClass
{
    BOOL result = [self properIsKindOfClassIsNSArray] && [aClass properIsKindOfClassIsNSArray];
    
    if (!result) {
        result = [self properIsKindOfClassIsNSDictionary] && [aClass properIsKindOfClassIsNSDictionary];
    }
    
    return result;
}

+ (BOOL)properIsKindOfClass:(Class)aClass
{
    BOOL result = [self isSubclassOfClass:aClass];
    
    if (!result) {
        result = [aClass isSubclassOfClass:self];
    }
    if (!result) {
        result = [aClass fixedForLiteralClassesIsSubclassOfClass:self];
    }
    
    return result;
}

- (BOOL)properIsKindOfClass:(Class)aClass
{
    return [[self class] properIsKindOfClass:aClass];
}

@end
