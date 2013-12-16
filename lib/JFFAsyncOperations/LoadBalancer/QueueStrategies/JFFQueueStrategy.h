#import <Foundation/Foundation.h>

@class JFFBaseLoaderOwner;

@protocol JFFQueueStrategy <NSObject>

- (JFFBaseLoaderOwner *)firstPendingLoader;
- (void)executePendingLoader:(JFFBaseLoaderOwner *)pendingLoader;

@end
