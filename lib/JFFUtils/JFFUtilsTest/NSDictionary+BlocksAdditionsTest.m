#import "NSDictionary+BlocksAdditionsTest.h"

@implementation NSDictionary_BlocksAdditionsTest

- (void)testMapMethod
{
    NSDictionary *dict = @{
    @"1" : @1,
    @"2" : @2,
    @"3" : @3,
    };
    
    NSDictionary *result = [dict map:^id(id key, id object) {
        NSUInteger num = [object unsignedIntegerValue];
        return @(num * [key integerValue]);
    }];
    
    STAssertTrue([result count] == 3, nil);
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 6.)
        STAssertFalse([result isKindOfClass:[NSMutableDictionary class]], nil);
    STAssertTrue ([result isKindOfClass:[NSDictionary class]], nil);
    
    STAssertEqualObjects(@1, result[@"1"], nil);
    STAssertEqualObjects(@4, result[@"2"], nil);
    STAssertEqualObjects(@9, result[@"3"], nil);
    
    STAssertThrows({
        [dict map:^id(id key, id object) {
            NSUInteger num = [object unsignedIntegerValue];
            if (num == 3)
                return nil;
            return @(num * 2);
        }];
    }, nil);
}

- (void)testEachMethod
{
    NSDictionary *dict = @{
    @"1" : @1,
    @"2" : @2,
    @"3" : @3,
    };
    
    NSMutableArray *keys    = [NSMutableArray new];
    NSMutableArray *objects = [NSMutableArray new];
    
    [dict each:^void(id key, id object) {
        [keys    addObject:key];
        [objects addObject:object];
    }];
    
    STAssertTrue([keys    count] == 3, nil);
    
    for (id key in [dict allKeys]) {
        STAssertTrue([keys containsObject:key], nil);
    }
    
    STAssertTrue([objects count] == 3, nil);
    
    for (id value in [dict allValues]) {
        STAssertTrue([objects containsObject:value], nil);
    }
}

- (void)testCountMethod
{
    NSDictionary *dict = @{
    @"1" : @1,
    @"2" : @2,
    @"3" : @3,
    };
    
    NSUInteger count = [dict count:^BOOL(id key, id object) {
        return [@2 isEqualToNumber:object] && [@"2" isEqualToString:key];
    }];
    
    STAssertTrue(count == 1, nil);
}

- (void)testKeyMethod
{
    NSDictionary *dict = @{
    @"one"   : @1,
    @"two"   : @2,
    @"three" : @3,
    };
    
    NSDictionary *result = [dict mapKey:^id(id key, id object) {
        return [[key uppercaseString] stringByAppendingFormat:@"%@", object];
    }];
    
    STAssertTrue([result count] == 3, nil);
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 6.)
        STAssertFalse([result isKindOfClass:[NSMutableDictionary class]], nil);
    STAssertTrue([result isKindOfClass:[NSDictionary class]], nil);
    
    STAssertEqualObjects(@1, result[@"ONE1"  ], nil);
    STAssertEqualObjects(@2, result[@"TWO2"  ], nil);
    STAssertEqualObjects(@3, result[@"THREE3"], nil);
    
    STAssertThrows({
        [dict map:^id(id key, id object) {
            NSUInteger num = [object unsignedIntegerValue];
            if (num == 3)
                return nil;
            return [key uppercaseString];
        }];
    }, nil);
}

- (void)testMapAndErrorMethodWithoutError
{
    NSDictionary *dict = @{
    @"1" : @1,
    @"2" : @2,
    @"3" : @3,
    };
    
    NSError *error;
    
    NSDictionary *result = [dict map:^id(id key, id object, NSError **outError) {
        STAssertTrue(outError != NULL, nil);
        NSUInteger num = [object unsignedIntegerValue];
        return @(num * [key integerValue]);
    } error:&error];
    
    STAssertNil(error, nil);
    
    STAssertTrue([result count] == 3, nil);
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 6.)
        STAssertFalse([result isKindOfClass:[NSMutableDictionary class]], nil);
    STAssertTrue([result isKindOfClass:[NSDictionary class]], nil);
    
    STAssertEqualObjects(@1, result[@"1"], nil);
    STAssertEqualObjects(@4, result[@"2"], nil);
    STAssertEqualObjects(@9, result[@"3"], nil);
}

- (void)testMapAndErrorMethodWithError
{
    NSDictionary *dict = @{
    @"1" : @1,
    @"2" : @2,
    @"3" : @3,
    };
    
    NSError *error;
    
    NSError *errorForMap = [JFFError newErrorWithDescription:@"test error"];
    
    NSDictionary *result = [dict map:^id(id key, id object, NSError **outError) {
        STAssertTrue(outError != NULL, nil);
        NSUInteger num = [object unsignedIntegerValue];
        if (num == 3) {
            *outError = errorForMap;
            return nil;
        }
        return @(num * [key integerValue]);
    } error:&error];
    
    STAssertNil(result, nil);
    STAssertNotNil(error , nil);
    
    STAssertTrue(errorForMap == error, nil);
}

@end
