#import <Foundation/Foundation.h>

typedef void (^JFFCancelScheduledBlock) ( void );
typedef void (^JFFScheduledBlock) ( JFFCancelScheduledBlock cancel_ );

@interface JFFScheduler : NSObject

//returns the shared scheduler
+(id)sharedByThreadScheduler;

//Add new block to scheduler which will be invoked on the current thread using the default mode after a delay,
//returning the block for canceling this invocation
//the invocation will be canceled at removing "scheduler" object from memory
-(JFFCancelScheduledBlock)addBlock:( JFFScheduledBlock )block_ duration:( NSTimeInterval )duration_;

//cancel all delayed invocations for self
-(void)cancelAllScheduledOperations;

@end
