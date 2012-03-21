#import "NSObject+Ownerships.h"

#include <objc/runtime.h>

static char ownershipsKey_;

@implementation NSObject (Ownerships)

//should not autorelease returned value
-(NSMutableArray*)ownerships
{
    if ( !objc_getAssociatedObject( self, &ownershipsKey_ ) )
    {
        objc_setAssociatedObject( self, &ownershipsKey_, [ NSMutableArray new ], OBJC_ASSOCIATION_RETAIN_NONATOMIC );
    }
    return objc_getAssociatedObject( self, &ownershipsKey_ );
}

@end
