#import <Foundation/Foundation.h>

@interface JFFSharedDispatchersStorage : NSObject

+(dispatch_queue_t)dispatchQueueGetOrCreate:( const char *)label_
                                  attribute:( dispatch_queue_attr_t )attr_;

@end
