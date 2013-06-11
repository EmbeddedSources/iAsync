#import "JFFBaseStrategy.h"
#import "JFFQueueStrategy.h"

#import <Foundation/Foundation.h>

@interface JFFStrategyFifo : JFFBaseStrategy <JFFQueueStrategy>
@end
