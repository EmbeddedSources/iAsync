#import "NSArray+NoThrowObjectAtIndex.h"

#import "JFFClangLiterals.h"

@implementation NSArray (NoThrowObjectAtIndex)

-(id)noThrowObjectAtIndex:( NSUInteger )index_
{
   if ( [ self count ] <= index_ )
      return nil;

   return self[ index_ ];
}

@end
