#import <Foundation/Foundation.h>

@interface JFFAssignProxy : NSProxy

@property (nonatomic, unsafe_unretained, readonly) id target;

- (instancetype)initWithTarget:(id)target;

@end
