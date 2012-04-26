#import <Foundation/Foundation.h>

@interface JFFAssignProxy : NSProxy

@property ( nonatomic, unsafe_unretained, readonly ) id target;

-(id)initWithTarget:( id )target_;

@end
