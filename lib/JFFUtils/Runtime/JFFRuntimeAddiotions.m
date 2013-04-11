#include "JFFRuntimeAddiotions.h"

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

const char *block_getTypeEncoding(id block)
{
    //http://clang.llvm.org/docs/Block-ABI-Apple.html
    //https://github.com/ebf/CTObjectiveCRuntimeAdditions/blob/master/CTObjectiveCRuntimeAdditions/CTObjectiveCRuntimeAdditions/CTBlockDescription.h
    //
    struct JFF_Block_literal_1 {
        void *isa; // initialized to &_NSConcreteStackBlock or &_NSConcreteGlobalBlock
        int flags;
        int reserved;
        void (*invoke)(void *, ...);
        struct Block_descriptor_1 {
            unsigned long int reserved; // NULL
            unsigned long int size;         // sizeof(struct Block_literal_1)
            // optional helper functions
            void (*copy_helper)(void *dst, void *src);     // IFF (1<<25)
            void (*dispose_helper)(void *src);             // IFF (1<<25)
            // required ABI.2010.3.16
            const char *signature;                         // IFF (1<<30)
        } *descriptor;
        // imported variables
    };
    
    typedef enum {
        CTBlockDescriptionFlagsHasCopyDispose = (1 << 25),
        CTBlockDescriptionFlagsHasCtor = (1 << 26), // helpers have C++ code
        CTBlockDescriptionFlagsIsGlobal = (1 << 28),
        CTBlockDescriptionFlagsHasStret = (1 << 29), // IFF BLOCK_HAS_SIGNATURE
        CTBlockDescriptionFlagsHasSignature = (1 << 30)
    } CTBlockDescriptionFlags;
    
    struct JFF_Block_literal_1 *blockRef = (__bridge struct JFF_Block_literal_1 *)block;
    
    int flags = blockRef->flags;
    //unsigned long int size = blockRef->descriptor->size;
    
    if (flags & CTBlockDescriptionFlagsHasSignature) {
        size_t signatureLocation = (size_t)blockRef->descriptor;
        signatureLocation += sizeof(unsigned long int);
        signatureLocation += sizeof(unsigned long int);
        
        if (flags & CTBlockDescriptionFlagsHasCopyDispose) {
            signatureLocation += sizeof(void(*)(void *dst, void *src));
            signatureLocation += sizeof(void (*)(void *src));
        }
        
        const char *signature = (*(const char **)signatureLocation);
        
        return signature;
    }
    
    return NULL;
}

void invokeMethosBlockWithArgsAndReturnValue(id targetObjectOrBlock,
                                             const char *signature,
                                             SEL selectorOrNullForBlock,
                                             va_list args,
                                             id *selfArgumentPtr,
                                             void *returnValuePtr)
{
    NSMethodSignature *signatureObj = [NSMethodSignature signatureWithObjCTypes:signature];
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signatureObj];
    //[invocation retainArguments];
    
    if (selectorOrNullForBlock != NULL) {
        
        invocation.selector = selectorOrNullForBlock;
    } else {
    
        //for block call
        [invocation setArgument:selfArgumentPtr atIndex:1];
    }
    
    const char *signaturePtr = signature;
    signaturePtr = NSGetSizeAndAlignment(signaturePtr, NULL, NULL);
    signaturePtr = NSGetSizeAndAlignment(signaturePtr, NULL, NULL);
    signaturePtr = NSGetSizeAndAlignment(signaturePtr, NULL, NULL);
    
    assert(strlen(signaturePtr) != 0);
    long long value;
    sscanf(signaturePtr, "%lld", &value);
    
    size_t startAddress = (size_t)args - value * 2;
    
    /*for (NSUInteger indx = 0; indx < 40; ++indx) {
     
     NSUInteger *ptr = (NSUInteger *)(startAddress + indx * 4);
     NSLog(@"ptr: %p val: %d", ptr, *ptr);
     }*/
    
    for (NSUInteger index = 2; index < signatureObj.numberOfArguments; ++index) {
        
        signaturePtr = NSGetSizeAndAlignment(signaturePtr, NULL, NULL);
        
        assert(strlen(signaturePtr) != 0);
        long long value;
        sscanf(signaturePtr, "%lld", &value);
        
        size_t currAddress = startAddress + value;
        
        [invocation setArgument:currAddress
                        atIndex:index];
    }
    
    [invocation invokeWithTarget:targetObjectOrBlock];
    
    if (returnValuePtr != NULL)
        [invocation getReturnValue:returnValuePtr];
}
