#import "JNAbstractConnection+Constructor.h"

@implementation JNAbstractConnection( Constructor )

-(id)privateInit
{
   self = [ super init ];
   if ( nil == self )
   {
      return nil;
   }

   return self;
}

@end
