#ifndef JFFUtils_JFFBlockRuntimeAddiotions_h
#define JFFUtils_JFFBlockRuntimeAddiotions_h

#include <stdarg.h>
#include <objc/objc.h>

@class NSArray;

#ifdef __cplusplus
extern "C" {
#endif
    
    void enumerateAllClassesWithBlock(void(^)(Class));
    
    const char *block_getTypeEncoding(id block);
    
    void invokeMethosBlockWithArgsAndReturnValue(id targetObjectOrBlock,
                                                 const char *signature,
                                                 SEL selectorOrNullForBlock,
                                                 va_list args,
                                                 id *selfArgumentPtr,
                                                 void *returnValuePtr);
    
    
#ifdef __cplusplus
} /* closing brace for extern "C" */
#endif

#endif //JFFUtils_JFFBlockRuntimeAddiotions_h
