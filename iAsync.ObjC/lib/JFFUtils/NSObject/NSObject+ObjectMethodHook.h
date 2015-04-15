#import <Foundation/Foundation.h>

typedef id(^JFFPreviousObserverBlockGetter)();

typedef id(^JFFMethodObserverBlock)(JFFPreviousObserverBlockGetter previousBlockGetter);

@interface NSObject (ObjectMethodHook)

//- no thread safe method, use only from one thread
//- works only for instance methods

//TODO add static version of method
- (void)addMethodHook:(JFFMethodObserverBlock)observer
             selector:(SEL)selector;

@end
