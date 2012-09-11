#import <Foundation/Foundation.h>

@class JFFMutableAssignArray;

@interface JFFProxyDelegatesDispatcher : NSObject

+ (id)newProxyDelegatesDispatcherWithRealDelegate:(id)realDelegate
                                        delegates:(JFFMutableAssignArray *)delegates;

@end
