#import "NSObject+Const0.h"

@interface JFFConst0 : NSObject
@end

@implementation JFFConst0

-(void)forwardInvocation:( NSInvocation* )invocation_
{
}

-(NSMethodSignature*)methodSignatureForSelector:( SEL )selector_
{
   return [ [ self class ] instanceMethodSignatureForSelector: @selector( doNothing ) ];
}

-(NSUInteger)doNothing
{
   return 0;
}

@end

@implementation NSObject (Const0)

+(id)objectThatAlwaysReturnsZeroForAnyMethod
{
    static dispatch_once_t once_;
    static id instance_;
    dispatch_once( &once_, ^{ instance_ = [ JFFConst0 new ]; } );
    return instance_;
}

@end
