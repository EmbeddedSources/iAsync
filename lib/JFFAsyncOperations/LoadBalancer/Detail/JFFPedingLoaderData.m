#import "JFFPedingLoaderData.h"

@implementation JFFPedingLoaderData

-(void)dealloc
{
    [_nativeLoader     release];
    [_progressCallback release];
    [_cancelCallback   release];
    [_doneCallback     release];
    
    [super dealloc];
}

@end
