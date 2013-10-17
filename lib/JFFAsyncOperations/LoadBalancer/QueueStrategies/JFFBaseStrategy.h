#import <Foundation/Foundation.h>

@class
JFFQueueState,
JFFBaseLoaderOwner;

@interface JFFBaseStrategy : NSObject
{
@protected
    JFFQueueState *_queueState;
}

- (void)executePendingLoader:(JFFBaseLoaderOwner *)pendingLoader;

- (instancetype)initWithQueueState:(JFFQueueState *)queueState;

@end
