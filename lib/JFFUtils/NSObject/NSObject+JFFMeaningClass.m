#import "NSObject+JFFMeaningClass.h"

#import <objc/runtime.h>

@implementation NSObject (JFFMeaningClass)

+ (Class)jffMeaningClass
{
    //CFArray
    {
        //TODO crash when release mode
//        static Class literalArrayClass = nil;
//        if (!literalArrayClass) {
//            const void* cArray[] = {};
//            CFArrayRef arrayRef = CFArrayCreate(NULL,
//                                                cArray,
//                                                1,
//                                                NULL
//                                                );
//            literalArrayClass = [(__bridge id)arrayRef class];
//        }
//        
//        if (self == literalArrayClass)
//            return [NSArray class];
    }
    //NSArray
    {
        static Class literalArrayClass = nil;
        if (!literalArrayClass)
            literalArrayClass = [@[] class];
        
        if (self == literalArrayClass)
            return [NSArray class];
    }
    //NSMutableArray
    {
        static Class literalMutableArrayClass = nil;
        if (!literalMutableArrayClass)
            literalMutableArrayClass = [[@[] mutableCopy] class];
        
        if (self == literalMutableArrayClass)
            return [NSMutableArray class];
    }
    //NSDictionary
    {
        static Class literalDictionaryClass = nil;
        if (!literalDictionaryClass)
            literalDictionaryClass = [@{} class];
        
        if (self == literalDictionaryClass)
            return [NSDictionary class];
    }
    //CFDictionary
    {
        static Class literalDictionaryClass = nil;
        if (!literalDictionaryClass) {
            const void* keys  [] = {};
            const void* values[] = {};
            CFDictionaryRef dictRef = CFDictionaryCreate(
                                                         NULL,
                                                         keys,
                                                         values,
                                                         0,
                                                         NULL,
                                                         NULL
                                                         );
            literalDictionaryClass = [(__bridge id)dictRef class];
            CFRelease(dictRef);
        }
        
        if (self == literalDictionaryClass)
            return [NSDictionary class];
    }
    //CFString
    {
        {
            static Class literalStringClass = nil;
            if (!literalStringClass) {
                const char *cStr = "some str";
                CFStringRef stringRef = CFStringCreateWithCString(
                                                                  NULL,
                                                                  cStr,
                                                                  kCFStringEncodingUTF8
                                                                  );
                literalStringClass = [(__bridge id)stringRef class];
                CFRelease(stringRef);
            }
            
            if (self == literalStringClass)
                return [NSString class];
        }
        {
            static Class literalStringClass = nil;
            if (!literalStringClass) {
                const char *cStr = "";
                CFStringRef stringRef = CFStringCreateWithCString(
                                                                  NULL,
                                                                  cStr,
                                                                  kCFStringEncodingUTF8
                                                                  );
                literalStringClass = [(__bridge id)stringRef class];
                CFRelease(stringRef);
            }
            
            if (self == literalStringClass)
                return [NSString class];
        }
    }
    //NSString
    {
        static Class literalStringClass = nil;
        if (!literalStringClass)
            literalStringClass = [@"" class];
        
        if (self == literalStringClass)
            return [NSString class];
    }
    //NSMutableString
    {
        static Class literalMutableStringClass = nil;
        if (!literalMutableStringClass)
            literalMutableStringClass = [[@"" mutableCopy] class];
        
        if (self == literalMutableStringClass)
            return [NSMutableString class];
    }
    //NSNumber
    {
        static Class literalNumberClass = nil;
        if (!literalNumberClass)
            literalNumberClass = [@1 class];
        
        if (self == literalNumberClass)
            return [NSNumber class];
    }
    
    return self;
}

- (Class)jffMeaningClass
{
    return [[self class] jffMeaningClass];
}

@end
