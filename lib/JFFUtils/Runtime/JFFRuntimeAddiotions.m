#include "JFFRuntimeAddiotions.h"

#include <objc/runtime.h>

void enumerateAllClassesWithBlock(void(^block)(Class))
{
    NSCParameterAssert(block && "block is undefined");
    
    int numClasses = objc_getClassList(NULL, 0);
    Class classes[numClasses];
    
    numClasses = objc_getClassList(classes, numClasses);
    
    for (int index = 0; index < numClasses; ++index) {
        
        @autoreleasepool {
            
            Class class = classes[index];
            NSString *className = NSStringFromClass(class);
            if (![className isEqualToString:@"PFUbiquityLocation"])
            if (class_getClassMethod(class, @selector(conformsToProtocol:)))
            {
                block(class);
            }
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
    
    typedef NS_OPTIONS(uint32_t, CTBlockDescriptionFlags)
    {
        CTBlockDescriptionFlagsHasCopyDispose = (1 << 25),
        CTBlockDescriptionFlagsHasCtor = (1 << 26), // helpers have C++ code
        CTBlockDescriptionFlagsIsGlobal = (1 << 28),
        CTBlockDescriptionFlagsHasStret = (1 << 29), // IFF BLOCK_HAS_SIGNATURE
        CTBlockDescriptionFlagsHasSignature = (1 << 30)
    };
    
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
    
    {
        NSString *errorDescription = [[NSString alloc] initWithFormat:@"invalid signature: %s", signature];
        NSCAssert(strlen(signaturePtr) != 0, errorDescription);
    }
    long long value;
    sscanf(signaturePtr, "%lld", &value);
    
    size_t startAddress = (size_t)args - value * 2;
    
    /*for (NSUInteger indx = 0; indx < 40; ++indx) {
     
     NSUInteger *ptr = (NSUInteger *)(startAddress + indx * 4);
     NSLog(@"ptr: %p val: %d", ptr, *ptr);
     }*/
    
    for (NSUInteger index = 2; index < signatureObj.numberOfArguments; ++index) {
        
        signaturePtr = NSGetSizeAndAlignment(signaturePtr, NULL, NULL);
        
        {
            NSString *errorDescription = [[NSString alloc] initWithFormat:@"invalid signature: %s", signaturePtr];
            NSCAssert(strlen(signaturePtr) != 0, errorDescription);
        }
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

@interface JFFWeakGetterProxy : NSObject

@property (weak, nonatomic) id targetObject;

@end

@implementation JFFWeakGetterProxy
@end

typedef NS_ENUM(NSUInteger, MemoryManagement)
{
    MemoryManagementAssign,
    MemoryManagementCopy,
    MemoryManagementRetain,
    MemoryManagementWeak
};

typedef id(^WeakGetterBlock)(id self_);

inline static IMP getGetterImplementation(const MemoryManagement memoryManagement, SEL getter)
{
    if (memoryManagement == MemoryManagementWeak) {
        
        return imp_implementationWithBlock(^id(id self_) {
            
            JFFWeakGetterProxy *proxy = objc_getAssociatedObject(self_, getter);
            
            id result = proxy.targetObject;
            
            if (result)
                return result;
            
            if (proxy)
                objc_setAssociatedObject(self_, getter, nil, OBJC_ASSOCIATION_RETAIN);
            
            return nil;
        });
    }
    
    return imp_implementationWithBlock(^id(id self_) {
        return objc_getAssociatedObject(self_, getter);
    });
}

inline static IMP getSetterImplementation(const MemoryManagement memoryManagement,
                                          SEL getter,
                                          objc_AssociationPolicy associationPolicy)
{
    if (memoryManagement == MemoryManagementWeak) {
        
        return imp_implementationWithBlock(^(id self_, id object) {
            
            JFFWeakGetterProxy *proxy = objc_getAssociatedObject(self_, getter);
            
            if (!object) {
                
                if (proxy)
                    objc_setAssociatedObject(self_, getter, nil, OBJC_ASSOCIATION_RETAIN);
                return;
            }
            
            if (!proxy) {
                
                proxy = [JFFWeakGetterProxy new];
                objc_setAssociatedObject(self_, getter, proxy, OBJC_ASSOCIATION_RETAIN);
            }
            
            proxy.targetObject = object;
        });
    }
    
    return imp_implementationWithBlock(^(id self_, id object) {
        
        objc_setAssociatedObject(self_, getter, object, associationPolicy);
    });
}

//based on https://github.com/ebf/CTObjectiveCRuntimeAdditions/blob/master/CTObjectiveCRuntimeAdditions/CTObjectiveCRuntimeAdditions/CTObjectiveCRuntimeAdditions.m

void jClass_implementProperty(Class cls, NSString *propertyName)
{
    NSCAssert(cls != Nil, @"class is required");
    NSCAssert(propertyName != nil, @"propertyName is required");
    
    objc_property_t property = class_getProperty(cls, propertyName.UTF8String);
    
    unsigned int count = 0;
    objc_property_attribute_t *attributes = property_copyAttributeList(property, &count);
    
    MemoryManagement memoryManagement = MemoryManagementAssign;
    BOOL isNonatomic = NO;
    
    NSString *getterName = nil;
    NSString *setterName = nil;
    NSString *encoding   = nil;
    
    for (int i = 0; i < count; i++) {
        objc_property_attribute_t attribute = attributes[i];
        
        switch (attribute.name[0]) {
            case 'N':
                isNonatomic = YES;
                break;
            case '&':
                memoryManagement = MemoryManagementRetain;
                break;
            case 'C':
                memoryManagement = MemoryManagementCopy;
                break;
            case 'G':
                getterName = [[NSString alloc] initWithFormat:@"%s", attribute.value];
                break;
            case 'S':
                setterName = [[NSString alloc] initWithFormat:@"%s", attribute.value];
                break;
            case 'T':
                encoding = [[NSString alloc] initWithFormat:@"%s", attribute.value];
                break;
            case 'W':
                memoryManagement = MemoryManagementWeak;
                break;
            default:
                break;
        }
    }
    
    NSCAssert([encoding length] != 0, @"encoding is required");
    
    if (!getterName) {
        getterName = propertyName;
    }
    
    if (!setterName) {
        NSString *firstLetter = [propertyName substringToIndex:1];
        setterName = [propertyName stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[NSString stringWithFormat:@"set%@", firstLetter.uppercaseString]];
        setterName = [setterName stringByAppendingString:@":"];
    }
    
    NSCAssert([encoding characterAtIndex:0] != '{', @"structs are not supported");
    NSCAssert([encoding characterAtIndex:0] != '(', @"unions are not supported");
    
    SEL getter = NSSelectorFromString(getterName);
    SEL setter = NSSelectorFromString(setterName);
    
    if (encoding.UTF8String[0] == @encode(id)[0]) {
        
        IMP getterImplementation = getGetterImplementation(memoryManagement, getter);
        
        objc_AssociationPolicy associationPolicy = 0;
        
        if (memoryManagement == MemoryManagementCopy) {
            associationPolicy = isNonatomic?OBJC_ASSOCIATION_COPY_NONATOMIC:OBJC_ASSOCIATION_COPY;
        } else {
            associationPolicy = isNonatomic?OBJC_ASSOCIATION_RETAIN_NONATOMIC:OBJC_ASSOCIATION_RETAIN;
        }
        
        IMP setterImplementation = getSetterImplementation(memoryManagement, getter, associationPolicy);
        
        BOOL added1 = class_addMethod(cls, getter, getterImplementation, "@8@0:4");//was "@@:"
        BOOL added2 = class_addMethod(cls, setter, setterImplementation, "v@:@");
        
        NSCAssert(added1 && added2, @"encoding is required");
        
        return;
    }
    
    objc_AssociationPolicy associationPolicy = isNonatomic ? OBJC_ASSOCIATION_RETAIN_NONATOMIC : OBJC_ASSOCIATION_RETAIN;
    
#define CASE(type, selectorpart) if (encoding.UTF8String[0] == @encode(type)[0]) {\
IMP getterImplementation = imp_implementationWithBlock(^type(id self) {\
return [objc_getAssociatedObject(self, getter) selectorpart##Value];\
});\
\
IMP setterImplementation = imp_implementationWithBlock(^(id self, type object) {\
objc_setAssociatedObject(self, getter, @(object), associationPolicy);\
});\
\
class_addMethod(cls, getter, getterImplementation, "@@:");\
class_addMethod(cls, setter, setterImplementation, "v@:@");\
\
return;\
}
    
    CASE(char, char);
    CASE(unsigned char, unsignedChar);
    CASE(short, short);
    CASE(unsigned short, unsignedShort);
    CASE(int, int);
    CASE(unsigned int, unsignedInt);
    CASE(long, long);
    CASE(unsigned long, unsignedLong);
    CASE(long long, longLong);
    CASE(unsigned long long, unsignedLongLong);
    CASE(float, float);
    CASE(double, double);
    CASE(BOOL, bool);
    
#undef CASE
    
    NSCAssert(NO, @"encoding %@ in not supported", encoding);
}
