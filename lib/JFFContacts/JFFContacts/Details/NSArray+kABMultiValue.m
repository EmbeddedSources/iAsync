#import "NSArray+kABMultiValue.h"

@implementation NSArray (kABMultiValue)

+(id)arrayWithMultyValue:( ABMutableMultiValueRef )multyValue_
{
    CFIndex count_ = multyValue_
        ? ABMultiValueGetCount( multyValue_ )
        : 0;

    if ( 0 == count_ )
        return nil;

    NSArray* result_ = [ NSArray arrayWithCapacity: count_
                              ignoringNilsProducer: ^id( NSUInteger index_ )
    {
        CFTypeRef value_ = ABMultiValueCopyValueAtIndex( multyValue_, index_ );

        return ( __bridge_transfer NSString* )value_;
    } ];

    return result_;
}

@end
