#import "NSDecimalNumber+Increment.h"

@implementation NSDecimalNumber (Increment)

- (instancetype)instanceOne
{
    return [[self class] one];
}

- (instancetype)increment
{
    return [self decimalNumberByAdding:[self instanceOne]];
}

- (instancetype)decrement
{
    return [self decimalNumberBySubtracting:[self instanceOne]];
}

@end
