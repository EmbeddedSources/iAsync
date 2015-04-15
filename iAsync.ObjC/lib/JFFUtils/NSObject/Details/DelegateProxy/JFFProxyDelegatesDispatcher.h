#import <Foundation/Foundation.h>

@class JFFMutableAssignArray;

@interface JFFProxyDelegatesDispatcher : NSObject

+ (instancetype)newProxyDelegatesDispatcherWithRealDelegate:(id)realDelegate
                                                  delegates:(JFFMutableAssignArray *)delegates;

@end
