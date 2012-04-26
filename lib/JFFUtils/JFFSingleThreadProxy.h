#import <Foundation/Foundation.h>

typedef id (^JFFObjectFactory)( void );

@interface JFFSingleThreadProxy : NSProxy

+(id)singleThreadProxyWithTargetFactory:( JFFObjectFactory )factory_
                          dispatchQueue:( dispatch_queue_t )dispatch_queue_;

@end
