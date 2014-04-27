#import "JFFMeaningClassTest.h"

@implementation JFFMeaningClassTest

- (void)testJffMeaningClass:(Class)aClass
{
    XCTAssertTrue([[aClass class] jffMeaningClass] == aClass);
    XCTAssertTrue([[aClass new  ] jffMeaningClass] == aClass);
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
        //XCTAssertTrue( [[(__bridge id)arrayRef class] jffMeaningClass] == [NSArray class], nil);
        //!!! memory fail
        //XCTAssertTrue( [[[(__bridge id)arrayRef class] new] jffMeaningClass] == [NSArray class], nil);
        
        //!!! [[[(__bridge id)arrayRef mutableCopy] class] == [(__bridge id)arrayRef class] :-(
        //XCTAssertTrue( [[[(__bridge id)arrayRef mutableCopy] class] jffMeaningClass] == [NSMutableArray class], nil);
        //
        
        XCTAssertTrue([[[@[] class] new] jffMeaningClass] == [NSArray class]);
        
        XCTAssertTrue( [[@[] class] jffMeaningClass] == [NSArray class]);
        XCTAssertTrue([[[@[] class] new] jffMeaningClass] == [NSArray class]);
        
        XCTAssertTrue( [[[@[] mutableCopy] class] jffMeaningClass] == [NSMutableArray class]);
        XCTAssertTrue([[[[@[] mutableCopy] class] new] jffMeaningClass] == [NSMutableArray class]);
        
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
        
        XCTAssertTrue( [[(__bridge id)dictRef class] jffMeaningClass] == [NSDictionary class]);
        //!!! runtime fail
        //XCTAssertTrue( [[[(__bridge id)dictRef class] new] jffMeaningClass] == [NSDictionary class], nil);
        //!!!
        //XCTAssertTrue( [[[(__bridge id)dictRef mutableCopy] class] jffMeaningClass] == [NSDictionary class], nil);
        
        CFRelease(dictRef);
        
        NSMutableDictionary *dict = [NSMutableDictionary new];
        XCTAssertTrue( [[[dict copy] class] jffMeaningClass] == [NSDictionary class]);
        
        XCTAssertTrue( [[@{} class] jffMeaningClass] == [NSDictionary class]);
        //!!! runtime fail when call new for [[@{} mutableCopy] class]
//        XCTAssertTrue([[[@{} class] new] jffMeaningClass] == [NSDictionary class], nil);
        
        //!!! [[[@{} mutableCopy] class] == [@{} class] :-(
//        XCTAssertTrue( [[[@{} mutableCopy] class] jffMeaningClass] == [NSMutableDictionary class], nil);
//        XCTAssertTrue([[[[@{} mutableCopy] class] new] jffMeaningClass] == [NSMutableDictionary class], nil);
    }
    
    {
        const char *cStr = "str";
        CFStringRef stringRef = CFStringCreateWithCString (
                                                           NULL,
                                                           cStr,
                                                           kCFStringEncodingUTF8
                                                           );
        
        XCTAssertTrue( [[(__bridge id)stringRef class] jffMeaningClass] == [NSString class]);
        
        CFRelease(stringRef);
        
        XCTAssertTrue( [[@"a" class] jffMeaningClass] == [NSString class]);
        XCTAssertTrue( [[[@"a" class] new] jffMeaningClass] == [NSString class]);
        
        //!!! the same as empty CFString
//        XCTAssertTrue( [[[@"" mutableCopy] class] jffMeaningClass] == [NSMutableString class], nil);
        //!!! runtime fail when call new for [[@"" mutableCopy] class]
//        XCTAssertTrue([[[[@"" mutableCopy] class] new] jffMeaningClass] == [NSMutableString class], nil);
    }
    
    
    {
        XCTAssertTrue( [[@1 class] jffMeaningClass] == [NSNumber class]);
        //!!! strange fails :-(
//        XCTAssertTrue( [[[[@1 class] alloc] initWithBool:NO] jffMeaningClass] == [NSString class], nil);
        
        const double value;
        CFNumberRef numberRef = CFNumberCreate (
                                                NULL,
                                                kCFNumberDoubleType,
                                                &value
                                                );
        
        XCTAssertTrue( [[(__bridge id)numberRef class] jffMeaningClass] == [NSNumber class]);
        //!!! strange fails :-(
//        XCTAssertTrue( [[[[(__bridge id)numberRef class] alloc] initWithBool:NO] jffMeaningClass] == [NSNumber class], nil);
        
        CFRelease(numberRef);

    }
}

@end
