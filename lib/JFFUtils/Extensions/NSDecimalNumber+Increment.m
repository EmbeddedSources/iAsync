#import "NSDecimalNumber+Increment.h"

@implementation NSDecimalNumber( Increment )

-(NSDecimalNumber*)instanceOne
{
    return [ [ self class ] one ];
}

-(NSDecimalNumber*)increment
{
    return [ self decimalNumberByAdding: [ self instanceOne ] ];
}

-(NSDecimalNumber*)decrement
{
    return [ self decimalNumberBySubtracting: [ self instanceOne ] ];
}

@end
