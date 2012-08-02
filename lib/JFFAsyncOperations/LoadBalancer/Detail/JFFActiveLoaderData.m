#import "JFFActiveLoaderData.h"

@implementation JFFActiveLoaderData

-(void)dealloc
{
    [ self->_nativeLoader release ];
    [ self->_wrappedCancel release ];

    [ super dealloc ];
}

@end
