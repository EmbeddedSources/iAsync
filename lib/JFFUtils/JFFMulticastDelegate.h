#import <Foundation/Foundation.h>

@interface JFFMulticastDelegate : NSObject

- (void)addDelegate:(id)delegate;
- (void)removeDelegate:(id)delegate;
- (void)removeAllDelegates;

@end
