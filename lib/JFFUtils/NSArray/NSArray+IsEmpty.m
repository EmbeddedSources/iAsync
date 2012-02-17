#import "NSArray+IsEmpty.h"

@implementation NSArray ( IsEmpty )

-(BOOL)hasElements
{
   // Apple recommends checking "lastObject" instead of comparing "count" with zero
   return ( nil != [ self lastObject ] );
}

@end
