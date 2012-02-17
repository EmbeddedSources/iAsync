#import "NSObject+Ownerships.h"

#include <objc/runtime.h>

static char ownerships_key_;

@implementation NSObject (Ownerships)

//should not autorelease returned value
-(NSMutableArray*)ownerships
{
   if ( !objc_getAssociatedObject( self, &ownerships_key_ ) )
   {
      objc_setAssociatedObject( self, &ownerships_key_, [ NSMutableArray new ], OBJC_ASSOCIATION_RETAIN_NONATOMIC );
   }
   return objc_getAssociatedObject( self, &ownerships_key_ );
}

@end
