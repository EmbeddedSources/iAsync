#ifndef JFFAsyncOperations_JFFQueueExecutionOrder_h
#define JFFAsyncOperations_JFFQueueExecutionOrder_h

#import <Foundation/Foundation.h>

typedef NS_ENUM( NSInteger, JFFQueueExecutionOrder )
{
    JQOrderFifo   = 0,
    JQOrderStack  = 1,
    JQOrderRandom = 2,
};

#endif
