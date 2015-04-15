#import <Foundation/Foundation.h>

typedef void (^JFFCancelScheduledBlock) (void);
typedef void (^JFFScheduledBlock) (JFFCancelScheduledBlock cancel);

@interface JFFTimer : NSObject

//returns the shared timer
+ (instancetype)sharedByThreadTimer;

//Add new block to timer which will be invoked on the current thread using the default mode after a delay,
//returning the block for canceling this invocation
//the invocation will be canceled at removing "timer" object from memory
- (JFFCancelScheduledBlock)addBlock:(JFFScheduledBlock)block
                           duration:(NSTimeInterval)duration;

- (JFFCancelScheduledBlock)addBlock:(JFFScheduledBlock)block
                           duration:(NSTimeInterval)duration
                             leeway:(NSTimeInterval)leeway;

- (JFFCancelScheduledBlock)addBlock:(JFFScheduledBlock)block
                           duration:(NSTimeInterval)duration
                      dispatchQueue:(dispatch_queue_t)dispatchQueue;

- (JFFCancelScheduledBlock)addBlock:(JFFScheduledBlock)block
                           duration:(NSTimeInterval)duration
                             leeway:(NSTimeInterval)leeway
                      dispatchQueue:(dispatch_queue_t)dispatchQueue;

//cancel all delayed invocations for self
- (void)cancelAllScheduledOperations;

@end
