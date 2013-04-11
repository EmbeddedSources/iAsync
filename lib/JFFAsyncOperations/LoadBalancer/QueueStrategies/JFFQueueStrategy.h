#import <Foundation/Foundation.h>

@class JFFBaseLoaderOwner;
@class JFFQueueState;

@protocol JFFQueueStrategy <NSObject>

-(void)executePendingLoader;

-(id)initWithQueueState:( JFFQueueState* )queueState_;
-(JFFQueueState*)queueState;

@end
