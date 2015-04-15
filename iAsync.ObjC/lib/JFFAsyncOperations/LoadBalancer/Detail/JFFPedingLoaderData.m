#import "JFFPedingLoaderData.h"

@implementation JFFPedingLoaderData

- (void)unsubscribe
{
    _progressCallback = nil;
    _stateCallback    = nil;
    _doneCallback     = nil;
}

@end
