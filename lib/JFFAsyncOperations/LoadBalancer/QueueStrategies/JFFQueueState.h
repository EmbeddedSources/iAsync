#import <Foundation/Foundation.h>

@interface JFFQueueState : NSObject

@property ( nonatomic ) NSMutableArray* activeLoaders;
@property ( nonatomic ) NSMutableArray* pendingLoaders;

@end
