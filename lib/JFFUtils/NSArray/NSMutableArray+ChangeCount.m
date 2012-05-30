#import "NSMutableArray+ChangeCount.h"

@implementation NSMutableArray ( ChangeCount )

-(void)shrinkToSize:( NSUInteger )new_size_
{
    NSUInteger count_ = [ self count ];

    if ( count_ <= new_size_ )
    {
        //The size already fits
        return;
    }

    NSRange range_ = { 0, new_size_ };
    [ self setArray: [ self subarrayWithRange: range_ ] ];
}

@end
