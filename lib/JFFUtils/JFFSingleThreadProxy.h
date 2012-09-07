#import <Foundation/Foundation.h>

typedef id (^JFFObjectFactory)( void );

@interface JFFSingleThreadProxy : NSProxy

+(id)singleThreadProxyWithTargetFactory:( JFFObjectFactory )factory_
                          dispatchQueue:( dispatch_queue_t )dispatchQueue_;

@end
