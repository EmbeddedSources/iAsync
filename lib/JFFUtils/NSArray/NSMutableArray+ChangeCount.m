#import "NSMutableArray+ChangeCount.h"

@implementation NSMutableArray ( ChangeCount )

-(void)shrinkToSize:( NSUInteger )newSize_
{
    NSUInteger count_ = [ self count ];

    if ( count_ <= newSize_ )
    {
        //The size already fits
        return;
    }

    NSRange range_ = { 0, newSize_ };
    [ self setArray: [ self subarrayWithRange: range_ ] ];
}

@end
