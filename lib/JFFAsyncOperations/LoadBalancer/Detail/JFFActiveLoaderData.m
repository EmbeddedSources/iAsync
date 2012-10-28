#import "JFFActiveLoaderData.h"

@implementation JFFActiveLoaderData

-(void)dealloc
{
    [_nativeLoader  release];
    [_wrappedCancel release];
    
    [super dealloc];
}

@end
