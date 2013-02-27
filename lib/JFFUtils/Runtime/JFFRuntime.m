#import "JFFRuntime.h"

#include <objc/runtime.h>

void enumerateAllClassesWithBlock(void(^block)(Class))
{
    assert(block);
    
    int numClasses = objc_getClassList(NULL, 0);
    Class classes[sizeof(Class) * numClasses];
    
    numClasses = objc_getClassList(classes, numClasses);
    
    for (int index = 0; index < numClasses; ++index) {
        
        @autoreleasepool {
            
            Class class = classes[index];
            if (class_getClassMethod(class, @selector(conformsToProtocol:)))
                block(class);
        }
    }
}
