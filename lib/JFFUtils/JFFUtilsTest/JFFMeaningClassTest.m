#import "JFFMeaningClassTest.h"

@implementation JFFMeaningClassTest

- (void)testJffMeaningClass:(Class)aClass
{
    STAssertTrue([[aClass class] jffMeaningClass] == aClass, nil);
    STAssertTrue([[aClass new  ] jffMeaningClass] == aClass, nil);
}

- (void)testJFFMeaningClass
{
    [self testJffMeaningClass:[NSObject class]];
    [self testJffMeaningClass:[NSNotificationCenter class]];
    [self testJffMeaningClass:[NSArray class]];
    
    {
        const void* cArray[] = {@"test"};
        CFArrayRef arrayRef = CFArrayCreate(NULL,
                                            cArray,
                                            1,
                                            NULL
                                            );
        
        //fails TODO fix
        //STAssertTrue( [[(__bridge id)arrayRef class] jffMeaningClass] == [NSArray class], nil);
        //!!! memory fail
        //STAssertTrue( [[[(__bridge id)arrayRef class] new] jffMeaningClass] == [NSArray class], nil);
        
        //!!! [[[(__bridge id)arrayRef mutableCopy] class] == [(__bridge id)arrayRef class] :-(
        //STAssertTrue( [[[(__bridge id)arrayRef mutableCopy] class] jffMeaningClass] == [NSMutableArray class], nil);
        //
        
        STAssertTrue([[[@[] class] new] jffMeaningClass] == [NSArray class], nil);
        
        STAssertTrue( [[@[] class] jffMeaningClass] == [NSArray class], nil);
        STAssertTrue([[[@[] class] new] jffMeaningClass] == [NSArray class], nil);
        
        STAssertTrue( [[[@[] mutableCopy] class] jffMeaningClass] == [NSMutableArray class], nil);
        STAssertTrue([[[[@[] mutableCopy] class] new] jffMeaningClass] == [NSMutableArray class], nil);
        
        CFRelease(arrayRef);
    }
    
    {
        const void* keys  [] = {@"key1", @"key2"};
        const void* values[] = {@"val1", @"val2"};
        CFDictionaryRef dictRef = CFDictionaryCreate(
                                                     NULL,
                                                     keys,
                                                     values,
                                                     2,
                                                     NULL,
                                                     NULL
                                                     );
        
        STAssertTrue( [[(__bridge id)dictRef class] jffMeaningClass] == [NSDictionary class], nil);
        //!!! runtime fail
        //STAssertTrue( [[[(__bridge id)dictRef class] new] jffMeaningClass] == [NSDictionary class], nil);
        //!!!
        //STAssertTrue( [[[(__bridge id)dictRef mutableCopy] class] jffMeaningClass] == [NSDictionary class], nil);
        
        CFRelease(dictRef);
        
        NSMutableDictionary *dict = [NSMutableDictionary new];
        STAssertTrue( [[[dict copy] class] jffMeaningClass] == [NSDictionary class], nil);
        
        STAssertTrue( [[@{} class] jffMeaningClass] == [NSDictionary class], nil);
        //!!! runtime fail when call new for [[@{} mutableCopy] class]
//        STAssertTrue([[[@{} class] new] jffMeaningClass] == [NSDictionary class], nil);
        
        //!!! [[[@{} mutableCopy] class] == [@{} class] :-(
//        STAssertTrue( [[[@{} mutableCopy] class] jffMeaningClass] == [NSMutableDictionary class], nil);
//        STAssertTrue([[[[@{} mutableCopy] class] new] jffMeaningClass] == [NSMutableDictionary class], nil);
    }
    
    {
        const char *cStr = "str";
        CFStringRef stringRef = CFStringCreateWithCString (
                                                           NULL,
                                                           cStr,
                                                           kCFStringEncodingUTF8
                                                           );
        
        STAssertTrue( [[(__bridge id)stringRef class] jffMeaningClass] == [NSString class], nil);
        
        CFRelease(stringRef);
        
        STAssertTrue( [[@"a" class] jffMeaningClass] == [NSString class], nil);
        STAssertTrue( [[[@"a" class] new] jffMeaningClass] == [NSString class], nil);
        
        //!!! the same as empty CFString
//        STAssertTrue( [[[@"" mutableCopy] class] jffMeaningClass] == [NSMutableString class], nil);
        //!!! runtime fail when call new for [[@"" mutableCopy] class]
//        STAssertTrue([[[[@"" mutableCopy] class] new] jffMeaningClass] == [NSMutableString class], nil);
    }
    
    
    {
        STAssertTrue( [[@1 class] jffMeaningClass] == [NSNumber class], nil);
        //!!! strange fails :-(
//        STAssertTrue( [[[[@1 class] alloc] initWithBool:NO] jffMeaningClass] == [NSString class], nil);
        
        const double value;
        CFNumberRef numberRef = CFNumberCreate (
                                                NULL,
                                                kCFNumberDoubleType,
                                                &value
                                                );
        
        STAssertTrue( [[(__bridge id)numberRef class] jffMeaningClass] == [NSNumber class], nil);
        //!!! strange fails :-(
//        STAssertTrue( [[[[(__bridge id)numberRef class] alloc] initWithBool:NO] jffMeaningClass] == [NSNumber class], nil);
        
        CFRelease(numberRef);

    }
}

@end
