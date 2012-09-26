#import <Foundation/Foundation.h>

typedef id (^JFFObjectFactory)(void);

@interface JFFSingleThreadProxy : NSProxy

+ (id)singleThreadProxyWithTargetFactory:(JFFObjectFactory)factory
                           dispatchQueue:(dispatch_queue_t)dispatchQueue;

@end
