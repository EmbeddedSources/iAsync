#import "ProperIsKindOfClassTest.h"

#import "NSObject+ProperIsKindOfClass.h"

@implementation ProperIsKindOfClassTest

- (void)testNSStringIsKindOfNSObject
{
    id nsObjectClass = [NSObject class];
    id nsStringClass = [NSString class];
    id nsString      = [NSString new];
    
    STAssertTrue([nsString      isKindOfClass:nsObjectClass], @"ok");
    STAssertTrue([nsStringClass isKindOfClass:nsObjectClass], @"ok");
    STAssertTrue([nsStringClass isSubclassOfClass:nsObjectClass], @"ok");
    
    STAssertTrue([nsString      properIsKindOfClass:nsObjectClass], @"ok");
    STAssertTrue([nsStringClass properIsKindOfClass:nsObjectClass], @"ok");
}

- (void)testCFArrayIsKindOfNSArray
{
    const void* cArray[] = {@"test"};
    CFArrayRef arrayRef = CFArrayCreate(NULL,
                                        cArray,
                                        1,
                                        NULL
                                        );
    
    id nsArrayClass        = [NSArray class];
    id nsArrayLiteralClass = [@[] class];
    
    id arrayRefClass = [(__bridge id)arrayRef class];
    
    STAssertTrue([(__bridge id)arrayRef isKindOfClass:nsArrayClass], @"ok");
    STAssertFalse([arrayRefClass        isKindOfClass:nsArrayClass], @"ok");
    STAssertTrue([arrayRefClass         isSubclassOfClass:nsArrayClass], @"ok");
    
    STAssertFalse([(__bridge id)arrayRef isKindOfClass:nsArrayLiteralClass], @"ok");
    STAssertFalse([arrayRefClass         isSubclassOfClass:nsArrayLiteralClass], @"ok");
    STAssertFalse([nsArrayClass          isSubclassOfClass:nsArrayLiteralClass], @"ok");

    STAssertTrue([(__bridge id)arrayRef properIsKindOfClass:nsArrayClass], @"ok");
    STAssertTrue([arrayRefClass         properIsKindOfClass:nsArrayClass], @"ok");

    STAssertTrue([(__bridge id)arrayRef properIsKindOfClass:nsArrayLiteralClass], @"ok");
    STAssertTrue([arrayRefClass         properIsKindOfClass:nsArrayLiteralClass], @"ok");
    
    CFRelease(arrayRef);
}

- (void)testCFNumberIsKindOfNSNumber
{
    const double value;
    CFNumberRef numberRef = CFNumberCreate (
                                            NULL,
                                            kCFNumberDoubleType,
                                            &value
                                            );
    
    id nsNumberClass = [NSNumber class];
    id nsNumberLiteralClass = [@1 class];
    
    id numberRefClass = [(__bridge id)numberRef class];
    
    STAssertTrue([(__bridge id)numberRef isKindOfClass:nsNumberClass], @"ok");
    STAssertFalse([numberRefClass        isKindOfClass:nsNumberClass], @"ok");
    STAssertTrue([numberRefClass         isSubclassOfClass:nsNumberClass], @"ok");
    
    STAssertTrue ([(__bridge id)numberRef isKindOfClass:nsNumberLiteralClass], @"ok");
    STAssertTrue ([numberRefClass         isSubclassOfClass:nsNumberLiteralClass], @"ok");
    STAssertFalse([nsNumberClass          isSubclassOfClass:nsNumberLiteralClass], @"ok");
    
    STAssertTrue([(__bridge id)numberRef properIsKindOfClass:nsNumberClass], @"ok");
    STAssertTrue([numberRefClass         properIsKindOfClass:nsNumberClass], @"ok");
    
    STAssertTrue([(__bridge id)numberRef properIsKindOfClass:nsNumberLiteralClass], @"ok");
    STAssertTrue([numberRefClass         properIsKindOfClass:nsNumberLiteralClass], @"ok");
    
    CFRelease(numberRef);
}

- (void)testCFStringIsKindOfNSString
{
    const char *cStr = "str";
    CFStringRef stringRef = CFStringCreateWithCString (
                                                       NULL,
                                                       cStr,
                                                       kCFStringEncodingUTF8
                                                       );
    
    id nsStringClass = [NSString class];
    id nsStringLiteralClass = [@"" class];
    
    id stringRefClass = [(__bridge id)stringRef class];
    
    STAssertTrue([(__bridge id)stringRef isKindOfClass:nsStringClass], @"ok");
    STAssertFalse([stringRefClass        isKindOfClass:nsStringClass], @"ok");
    STAssertTrue([stringRefClass         isSubclassOfClass:nsStringClass], @"ok");
    
    STAssertFalse([(__bridge id)stringRef isKindOfClass:nsStringLiteralClass], @"ok");
    STAssertFalse([stringRefClass         isSubclassOfClass:nsStringLiteralClass], @"ok");
    STAssertFalse([nsStringClass          isSubclassOfClass:nsStringLiteralClass], @"ok");

    STAssertTrue([(__bridge id)stringRef properIsKindOfClass:nsStringClass], @"ok");
    STAssertTrue([stringRefClass         properIsKindOfClass:nsStringClass], @"ok");
    
    STAssertTrue([(__bridge id)stringRef properIsKindOfClass:nsStringLiteralClass], @"ok");
    STAssertTrue([stringRefClass         properIsKindOfClass:nsStringLiteralClass], @"ok");
    
    CFRelease(stringRef);
}

- (void)testCFDictionaryIsKindOfNSSictionary
{
    const void* keys  [] = {@"key1", @"key2"};
    const void* values[] = {@"val1", @"val2"};
    CFDictionaryRef dictRef = CFDictionaryCreate (
                                                  NULL,
                                                  keys,
                                                  values,
                                                  2,
                                                  NULL,
                                                  NULL
                                                  );
    
    id nsDictionaryClass = [NSDictionary class];
    id nsDictionaryLiteralClass = [@{} class];
    
    id dictionaryRefClass = [(__bridge id)dictRef class];
    
    STAssertTrue([(__bridge id)dictRef isKindOfClass:nsDictionaryClass], @"ok");
    STAssertFalse([dictionaryRefClass  isKindOfClass:nsDictionaryClass], @"ok");
    STAssertTrue([dictionaryRefClass   isSubclassOfClass:nsDictionaryClass], @"ok");
    
    STAssertTrue([(__bridge id)dictRef isKindOfClass:nsDictionaryLiteralClass], @"ok");
    STAssertTrue([dictionaryRefClass   isSubclassOfClass:nsDictionaryLiteralClass], @"ok");
    STAssertFalse([nsDictionaryClass   isSubclassOfClass:nsDictionaryLiteralClass], @"ok");
    
    STAssertTrue([(__bridge id)dictRef properIsKindOfClass:nsDictionaryClass], @"ok");
    STAssertTrue([dictionaryRefClass   properIsKindOfClass:nsDictionaryClass], @"ok");
    
    STAssertTrue([(__bridge id)dictRef properIsKindOfClass:nsDictionaryLiteralClass], @"ok");
    STAssertTrue([dictionaryRefClass   properIsKindOfClass:nsDictionaryLiteralClass], @"ok");
    
    CFRelease(dictRef);
}

- (void)testIssuesInFoundation
{
    //issue
    {
        const char *cStr = "str";
        CFStringRef stringRef = CFStringCreateWithCString (
                                                           NULL,
                                                           cStr,
                                                           kCFStringEncodingUTF8
                                                           );
        
        id stringRefClass = [(__bridge id)stringRef class];
        
        STAssertFalse([stringRefClass isSubclassOfClass:[@"" class]], @"ok");
        STAssertTrue([[@"" class] isSubclassOfClass:stringRefClass], @"ok");
    }
    //normal behaviour
    {
        const double value = 5.;
        CFNumberRef numberRef = CFNumberCreate (
                                                NULL,
                                                kCFNumberDoubleType,
                                                &value
                                                );
        
        id numberRefClass = [(__bridge id)numberRef class];
        
        STAssertTrue ([numberRefClass isSubclassOfClass:[@1  class]], @"ok");
    }
//    STAssertTrue([(__bridge id)dictRef    isSubclassOfClass:nsDictionaryLiteralClass], @"ok");
//    STAssertFalse([arrayRefClass          isSubclassOfClass:nsArrayLiteralClass], @"ok");
}

//TODO test also mutable Dictionary, Array, String and Number

@end
