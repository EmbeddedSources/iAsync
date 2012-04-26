#import "JFFActiveLoaderData.h"

@implementation JFFActiveLoaderData

@synthesize nativeLoader = _native_loader;
@synthesize wrappedCancel = _wrapped_cancel;

-(void)dealloc
{
    [ _native_loader release ];
    [ _wrapped_cancel release ];

    [ super dealloc ];
}

@end
