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
        
        STAssertTrue(1 == [dict1 count], @"Contains 1 object");
        STAssertTrue(1 == [dict2 count], @"Contains 1 object");
    }
    
    STAssertTrue(targetDeallocated, @"Target should be dealloced");
    STAssertTrue(0 == [dict1 count], @"Empty array");
    STAssertTrue(0 == [dict2 count], @"Empty array");
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
        
        STAssertTrue(dictDeallocated1, @"Target should be dealloced");
        STAssertTrue(dictDeallocated2, @"Target should be dealloced");
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
            
            STAssertTrue(dict[key1] == object1, @"Dict contains object_");
            STAssertTrue(dict[key2] == object2, @"Dict contains object_");
            STAssertTrue(dict[key3] == nil, @"Dict no contains object for key \"2\"");
            
            __block NSUInteger count = 0;
            
            [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if ([key isEqual:key1]) {
                    STAssertTrue(obj == object1, nil);
                    ++count;
                } else if ([key isEqual:key2]) {
                    STAssertTrue(obj == object2, nil);
                    ++count;
                } else {
                    STFail( @"should not be reached" );
                }
            }];
            
            STAssertTrue(count == 2, @"Dict no contains object for key \"2\"");
        }
        
        STAssertTrue(targetDeallocated, @"Target should be dealloced");
        STAssertTrue(0 == [dict count], @"Empty dict");
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
    
    STAssertTrue([result count] == 3, nil);
    
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 6.) {
        STAssertFalse([result isKindOfClass:[NSMutableDictionary class]], nil);
    }
    
    STAssertTrue([result isKindOfClass:[NSDictionary class]], nil);
    
    STAssertEqualObjects(@1, result[key1], nil);
    STAssertEqualObjects(@4, result[key2], nil);
    STAssertEqualObjects(@9, result[key3], nil);
    
    STAssertThrows({
        [dict map:^id(id key, id object) {
            NSUInteger num = [object unsignedIntegerValue];
            if (num == 3)
                return nil;
            return @(num * 2);
        }];
    }, nil);
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
        STAssertEqualObjects(obj, patternDict[key], nil);
    }];
    
    STAssertTrue(count == 3, nil);
    STAssertEqualObjects(resultDict, patternDict, nil);
    
    count = 0;
    
    [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        ++count;
        if (count == 2)
            *stop = YES;
    }];
    
    STAssertTrue(count == 2, nil);
}

@end
