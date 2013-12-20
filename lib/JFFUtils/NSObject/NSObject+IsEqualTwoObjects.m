#import "NSObject+IsEqualTwoObjects.h"

@implementation NSObject (IsEqualTwoObjects)

+(BOOL)object:(NSObject *)object1
     isEqualTo:(NSObject *)object2
{
    JUncertainLogicStates pointerCheckResult = [ self quickCheckObject: object1
                                                             isEqualTo: object2 ];
    if ( ULMaybe != pointerCheckResult )
    {
        return (BOOL)pointerCheckResult;
    }

    return [object1 isEqual:object2];
}

+(BOOL)objcBoolean:( BOOL )first
           xorWith:( BOOL )second
{
    return ![ self objcBoolean: first
                     isEqualTo: second ];
}

+(BOOL)objcBoolean:( BOOL )first
         isEqualTo:( BOOL )second
{
    return ( first && second ) || ( !first && !second );
}


+(JUncertainLogicStates)quickCheckObject:( id )first
                               isEqualTo:( id )second
{
    BOOL isBothNil = ( nil == first ) && ( nil == second );
    BOOL isAnyNil  = ( nil == first ) || ( nil == second );
    
    if ( isBothNil )
    {
        return ULTrue;
    }
    else if ( first == second )
    {
        return ULTrue;
    }
    else if ( isAnyNil )
    {
        return ULFalse;
    }
    
    return ULMaybe;
}

@end
