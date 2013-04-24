#import <Foundation/Foundation.h>

@protocol JFFQueueStrategy <NSObject>

- (void)executePendingLoader;

@end
