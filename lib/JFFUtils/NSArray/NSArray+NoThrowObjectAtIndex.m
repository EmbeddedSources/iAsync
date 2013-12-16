#import "NSArray+NoThrowObjectAtIndex.h"

#import "JFFClangLiterals.h"

@implementation NSArray (NoThrowObjectAtIndex)

- (id)noThrowObjectAtIndex:(NSUInteger)index
{
   if ([self count] <= index)
      return nil;
    
   return self[index];
}

- (id)firstObject
{
    return [self noThrowObjectAtIndex:0];
}

@end
