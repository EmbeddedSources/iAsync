#import "JFFMutableAssignKeyDictionaryTest.h"

@interface NSTestKeyObject : NSObject
@end

@implementation NSTestKeyObject
@end

@implementation JFFMutableAssignKeyDictionaryTest

-(void)testMutableAssignDictionaryAssignIssue
{
    JFFMutableAssignKeyDictionary *dict1;
    JFFMutableAssignKeyDictionary *dict2;
    __block BOOL targetDeallocated = NO;
    
    {
        NSObject *target = [NSTestKeyObject new];
        
        [target addOnDeallocBlock:^void(void) {
            targetDeallocated = YES;
        }];
        
        dict1 = [JFFMutableAssignKeyDictionary new];
        dict2 = [JFFMutableAssignKeyDictionary new];
        
        dict1[target] = [NSObject new];
        
        dict2[target] = [NSObject new];
        dict2[target] = [NSObject new];
        
        XCTAssertTrue(1 == [dict1 count], @"Contains 1 object");
        XCTAssertTrue(1 == [dict2 count], @"Contains 1 object");
    }
    
    XCTAssertTrue(targetDeallocated, @"Target should be dealloced");
    XCTAssertTrue(0 == [dict1 count], @"Empty array");
    XCTAssertTrue(0 == [dict2 count], @"Empty array");
}

- (void)testMutableAssignDictionaryFirstRelease
{
    {
        NSObject *target = [NSObject new];
        
        __block BOOL dictDeallocated1 = NO;
        __block BOOL dictDeallocated2 = NO;
        {
            JFFMutableAssignKeyDictionary *dict1 = [JFFMutableAssignKeyDictionary new];
            
            [dict1 addOnDeallocBlock:^void(void) {
                dictDeallocated1 = YES;
            }];
            
            dict1[target] = [NSObject new];
            
            ////
            
            JFFMutableAssignKeyDictionary *dict2 = [JFFMutableAssignKeyDictionary new];
            
            [dict2 addOnDeallocBlock:^void(void) {
                dictDeallocated2 = YES;
            }];
            
            dict2[target] = [NSObject new];
            dict2[target] = [NSObject new];
        }
        
        XCTAssertTrue(dictDeallocated1, @"Target should be dealloced");
        XCTAssertTrue(dictDeallocated2, @"Target should be dealloced");
    }
}

-(void)testObjectForKey
{
    @autoreleasepool {
        
        JFFMutableAssignKeyDictionary *dict = [JFFMutableAssignKeyDictionary new];
        
        __block BOOL targetDeallocated = NO;
        @autoreleasepool {
            
            NSObject *object1 = [NSObject new];
            NSObject *object2 = [NSObject new];
            
            NSObject *key1 = [NSObject new];
            NSObject *key2 = [NSObject new];
            NSObject *key3 = [NSObject new];
            
            [key1 addOnDeallocBlock: ^void( void ) {
                targetDeallocated = YES;
            }];
            
            dict[key1] = object1;
            [dict setObject:object2 forKey:key2];
            
            XCTAssertTrue(dict[key1] == object1, @"Dict contains object_");
            XCTAssertTrue(dict[key2] == object2, @"Dict contains object_");
            XCTAssertTrue(dict[key3] == nil, @"Dict no contains object for key \"2\"");
            
            __block NSUInteger count = 0;
            
            [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if ([key isEqual:key1]) {
                    XCTAssertTrue(obj == object1, @"pointers must be equal" );
                    ++count;
                } else if ([key isEqual:key2]) {
                    XCTAssertTrue(obj == object2, @"pointers must be equal");
                    ++count;
                } else {
                    XCTFail( @"should not be reached" );
                }
            }];
            
            XCTAssertTrue(count == 2, @"Dict no contains object for key \"2\"");
        }
        
        XCTAssertTrue(targetDeallocated, @"Target should be dealloced");
        XCTAssertTrue(0 == [dict count], @"Empty dict");
    }
}

- (void)testMapMethod
{
    JFFMutableAssignKeyDictionary *dict = [JFFMutableAssignKeyDictionary new];
    
    NSString *key1 = @"1";
    NSString *key2 = @"2";
    NSString *key3 = @"3";
    
    dict[key1] = @1;
    dict[key2] = @2;
    dict[key3] = @3;
    
    NSDictionary *result = [dict map:^id(id key, id object) {
        
        NSUInteger num = [object unsignedIntegerValue];
        return @(num * [key integerValue]);
    }];
    
    XCTAssertTrue([result count] == 3, @"count mismatch");
    
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 6.) {
        XCTAssertFalse([result isKindOfClass:[NSMutableDictionary class]], @"dictionary class mismatch");
    }
    
    XCTAssertTrue([result isKindOfClass:[NSDictionary class]], @"dictionary class mismatch");
    
    XCTAssertEqualObjects(@1, result[key1], @"key1 mismatch");
    XCTAssertEqualObjects(@4, result[key2], @"key2 mismatch");
    XCTAssertEqualObjects(@9, result[key3], @"key3 mismatch");
    
    XCTAssertThrows({
        [dict map:^id(id key, id object) {
            NSUInteger num = [object unsignedIntegerValue];
            if (num == 3)
                return nil;
            return @(num * 2);
        }];
    }, @"assert expected");
}

- (void)testEnumerateKeysAndObjectsUsingBlock
{
    NSString *key1 = @"1";
    NSString *key2 = @"2";
    NSString *key3 = @"3";
    
    NSDictionary *patternDict =
    @{
      key1 : @1,
      key2 : @2,
      key3 : @3,
      };
    
    JFFMutableAssignKeyDictionary *dict = [JFFMutableAssignKeyDictionary new];
    
    [patternDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        dict[key] = obj;
    }];
    
    __block NSUInteger count = 0;
    NSMutableDictionary *resultDict = [NSMutableDictionary new];
    
    [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        ++count;
        resultDict[key] = obj;
        XCTAssertEqualObjects(obj, patternDict[key], @"incorrect pattern match");
    }];
    
    XCTAssertTrue(count == 3,  @"incorrect pattern count");
    XCTAssertEqualObjects(resultDict, patternDict,  @"incorrect pattern dict");
    
    count = 0;
    
    [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        ++count;
        if (count == 2)
            *stop = YES;
    }];
    
    XCTAssertTrue(count == 2,  @"incorrect pattern count");
}

@end
