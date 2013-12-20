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
    
    XCTAssertTrue([result count] == 3);
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 6.)
        XCTAssertFalse([result isKindOfClass:[NSMutableDictionary class]]);
    XCTAssertTrue ([result isKindOfClass:[NSDictionary class]]);
    
    XCTAssertEqualObjects(@1, result[@"1"]);
    XCTAssertEqualObjects(@4, result[@"2"]);
    XCTAssertEqualObjects(@9, result[@"3"]);
    
    XCTAssertThrows({
        [dict map:^id(id key, id object) {
            NSUInteger num = [object unsignedIntegerValue];
            if (num == 3)
                return nil;
            return @(num * 2);
        }];
    });
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
    
    XCTAssertTrue([keys    count] == 3);
    
    for (id key in [dict allKeys]) {
        XCTAssertTrue([keys containsObject:key]);
    }
    
    XCTAssertTrue([objects count] == 3);
    
    for (id value in [dict allValues]) {
        XCTAssertTrue([objects containsObject:value]);
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
    
    XCTAssertTrue(count == 1);
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
    
    XCTAssertTrue([result count] == 3);
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 6.)
        XCTAssertFalse([result isKindOfClass:[NSMutableDictionary class]]);
    XCTAssertTrue([result isKindOfClass:[NSDictionary class]]);
    
    XCTAssertEqualObjects(@1, result[@"ONE1"  ]);
    XCTAssertEqualObjects(@2, result[@"TWO2"  ]);
    XCTAssertEqualObjects(@3, result[@"THREE3"]);
    
    XCTAssertThrows({
        [dict map:^id(id key, id object) {
            NSUInteger num = [object unsignedIntegerValue];
            if (num == 3)
                return nil;
            return [key uppercaseString];
        }];
    });
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
        XCTAssertTrue(outError != NULL);
        NSUInteger num = [object unsignedIntegerValue];
        return @(num * [key integerValue]);
    } error:&error];
    
    XCTAssertNil(error);
    
    XCTAssertTrue([result count] == 3);
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 6.)
        XCTAssertFalse([result isKindOfClass:[NSMutableDictionary class]]);
    XCTAssertTrue([result isKindOfClass:[NSDictionary class]]);
    
    XCTAssertEqualObjects(@1, result[@"1"]);
    XCTAssertEqualObjects(@4, result[@"2"]);
    XCTAssertEqualObjects(@9, result[@"3"]);
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
        XCTAssertTrue(outError != NULL);
        NSUInteger num = [object unsignedIntegerValue];
        if (num == 3) {
            *outError = errorForMap;
            return nil;
        }
        return @(num * [key integerValue]);
    } error:&error];
    
    XCTAssertNil(result);
    XCTAssertNotNil(error );
    
    XCTAssertTrue(errorForMap == error);
}

- (void)testAny
{
    NSArray *arr = @[@"a", @"b", @"c"];
    
    XCTAssertTrue([arr any:^BOOL(NSString *str) {
        return [str isEqualToString:@"a"];
    }]);
    
    XCTAssertTrue([arr any:^BOOL(NSString *str) {
        return [str isEqualToString:@"b"];
    }]);
    
    XCTAssertTrue([arr any:^BOOL(NSString *str) {
        return [str isEqualToString:@"c"];
    }]);
    
    XCTAssertFalse([arr any:^BOOL(NSString *str) {
        return [str isEqualToString:@"d"];
    }]);
}

- (void)testAll
{
    NSArray *arr = @[@"a", @"b", @"c"];
    
    XCTAssertTrue([arr all:^BOOL(NSString *str) {
        return [str length] == 1;
    }]);
    
    XCTAssertFalse([arr all:^BOOL(NSString *str) {
        return [str isEqualToString:@"a"] || [str isEqualToString:@"b"];
    }]);
}

@end
