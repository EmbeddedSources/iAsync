#import <Foundation/Foundation.h>

@interface JFFQueueState : NSObject
{
@public
    NSMutableArray *_activeLoaders;
    NSMutableArray *_pendingLoaders;
}

@end
