#import "JFFPedingLoaderData.h"

@implementation JFFPedingLoaderData

@synthesize nativeLoader = _native_loader;
@synthesize progressCallback = _progress_callback;
@synthesize cancelCallback = _cancel_callback;
@synthesize doneCallback = _done_callback;

-(void)dealloc
{
   [ _native_loader release ];
   [ _progress_callback release ];
   [ _cancel_callback release ];
   [ _done_callback release ];

   [ super dealloc ];
}

@end
