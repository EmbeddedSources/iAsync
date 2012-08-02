#import "JFFPedingLoaderData.h"

@implementation JFFPedingLoaderData

-(void)dealloc
{
    [ self->_nativeLoader     release ];
    [ self->_progressCallback release ];
    [ self->_cancelCallback   release ];
    [ self->_doneCallback     release ];

    [ super dealloc ];
}

@end
