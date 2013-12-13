#import "NSArray+kABMultiValue.h"

@implementation NSArray (kABMultiValue)

+ (instancetype)arrayWithMultyValue:(ABMutableMultiValueRef)multyValue
{
    CFIndex count = multyValue
        ?ABMultiValueGetCount(multyValue)
        :0;
    
    if (0 == count)
        return nil;
    
    NSArray *result = [NSArray arrayWithCapacity:count
                            ignoringNilsProducer:^id(NSUInteger index) {
    
        CFTypeRef value = ABMultiValueCopyValueAtIndex(multyValue, index);
        
        return (__bridge_transfer NSString *)value;
    }];
    
    return result;
}

@end
