#import "NSArray+NoThrowObjectAtIndex.h"

@implementation NSArray (NoThrowObjectAtIndex)

-(id)noThrowObjectAtIndex:( NSUInteger )index_
{
   if ( [ self count ] <= index_ )
      return nil;

   return [ self objectAtIndex: index_ ];
}

@end
