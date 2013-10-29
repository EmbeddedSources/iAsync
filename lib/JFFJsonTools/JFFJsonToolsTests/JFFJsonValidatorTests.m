#import <XCTest/XCTest.h>

#import "JFFJsonValidator.h"

#import "JFFJsonValidationError.h"

@interface JFFJsonValidatorTests : XCTestCase
@end

@implementation JFFJsonValidatorTests
{
    id _jsonObjectPatter;
}

- (void)setUp
{
    [super setUp];
    
    id nestedPattern =
    @{
    @"some_num"   : [NSNumber class],
    @"num_2"      : @2,
    @"some_str"   : [NSString class],
    @"str_22"     : @"22",
    @"some_null"  : [NSNull class],
    @"nested_ar"  : @[@[[NSNumber class]], @[@1, @"2"], @[@1, @2, [NSString class]]],
    };
    
    _jsonObjectPatter =
    @{
    @"some_num"   : [NSNumber class],
    @"num_2"      : @2,
    @"some_str"   : [NSString class],
    @"str_22"     : @"22",
    @"some_null"  : [NSNull class],
    @"nested_ar"  : @[@[[NSNumber class]], @[@1, @"2"], @[@1, @2, [NSString class]]],
    @"nested_obj" : nestedPattern,
    };
}

////// String type tests /////

- (void)testStringTypeMatch
{
    JFFJsonValidationError *error;
    
    BOOL result = [JFFJsonObjectValidator validateJsonObject:@"test"
                                             withJsonPattern:[NSString class]
                                                       error:&error];
    
    XCTAssertNil(error, @"error should be nil");
    XCTAssertTrue(result, @"ivalid result value");
}

- (void)testStringTypeMismatch
{
    JFFJsonValidationError *error;
    
    BOOL result = [JFFJsonObjectValidator validateJsonObject:@NO
                                             withJsonPattern:[NSString class]
                                                       error:&error];
    
    XCTAssertNotNil(error, @"error should be nil");
    XCTAssertFalse(result, @"ivalid result value");
}

////// String value tests /////

- (void)testStringValueMatch
{
    JFFJsonValidationError *error;
    
    BOOL result = [JFFJsonObjectValidator validateJsonObject:@"test"
                                             withJsonPattern:@"test"
                                                       error:&error];
    
    XCTAssertNil(error, @"error should be nil");
    XCTAssertTrue(result, @"ivalid result value");
}

- (void)testStringValueMismatch
{
    JFFJsonValidationError *error;
    
    BOOL result = [JFFJsonObjectValidator validateJsonObject:@"test"
                                             withJsonPattern:@"test1"
                                                       error:&error];
    
    XCTAssertNotNil(error, @"error should be nil");
    XCTAssertFalse(result, @"ivalid result value");
}

////// Number type tests /////

- (void)testNumberTypeMatch
{
    JFFJsonValidationError *error;
    
    BOOL result = [JFFJsonObjectValidator validateJsonObject:@(1)
                                             withJsonPattern:[NSNumber class]
                                                       error:&error];
    
    XCTAssertNil(error, @"error should be nil");
    XCTAssertTrue(result, @"ivalid result value");
}

- (void)testNumberTypeMismatch
{
    JFFJsonValidationError *error;
    
    BOOL result = [JFFJsonObjectValidator validateJsonObject:@""
                                             withJsonPattern:[NSNumber class]
                                                       error:&error];
    
    XCTAssertNotNil(error, @"error should be nil");
    XCTAssertFalse(result, @"ivalid result value");
}

////// Number value tests /////

- (void)testNumberValueMatch
{
    JFFJsonValidationError *error;
    
    BOOL result = [JFFJsonObjectValidator validateJsonObject:@(2)
                                             withJsonPattern:@(2)
                                                       error:&error];
    
    XCTAssertNil(error, @"error should be nil");
    XCTAssertTrue(result, @"ivalid result value");
}

- (void)testNumberValueMismatch
{
    JFFJsonValidationError *error;
    
    BOOL result = [JFFJsonObjectValidator validateJsonObject:@(3)
                                             withJsonPattern:@(2)
                                                       error:&error];
    
    XCTAssertNotNil(error, @"error should be nil");
    XCTAssertFalse(result, @"ivalid result value");
}

////// Null type tests /////

- (void)testNullTypeMatch
{
    {
        JFFJsonValidationError *error;

        BOOL result = [JFFJsonObjectValidator validateJsonObject:[NSNull null]
                                                 withJsonPattern:[NSNumber class]
                                                           error:&error];

        XCTAssertNotNil(error, @"error should be nil");
        XCTAssertFalse(result, @"ivalid result value");
    }
    {
        JFFJsonValidationError *error;
        
        BOOL result = [JFFJsonObjectValidator validateJsonObject:[NSNull null]
                                                 withJsonPattern:[NSString class]
                                                           error:&error];
        
        XCTAssertNotNil(error, @"error should be nil");
        XCTAssertFalse(result, @"ivalid result value");
    }
}

////// NSArray type tests /////

- (void)testArrayTypeMatch
{
    {
        JFFJsonValidationError *error;
        
        BOOL result = [JFFJsonObjectValidator validateJsonObject:@[@1, @2, @3]
                                                 withJsonPattern:[NSArray class]
                                                           error:&error];

        XCTAssertNil(error, @"error should be nil");
        XCTAssertTrue(result, @"ivalid result value");
    }
    
    {
        JFFJsonValidationError *error;

        BOOL result = [JFFJsonObjectValidator validateJsonObject:@[@1, @2, @3]
                                                 withJsonPattern:@[[NSNumber class]]
                                                           error:&error];

        XCTAssertNil(error, @"error should be nil");
        XCTAssertTrue(result, @"ivalid result value");
    }
}

- (void)testArrayTypeMismatch
{
    {
        JFFJsonValidationError *error;
        
        BOOL result = [JFFJsonObjectValidator validateJsonObject:@{}
                                                 withJsonPattern:[NSArray class]
                                                           error:&error];
        
        XCTAssertNotNil(error, @"error should be nil");
        XCTAssertFalse(result, @"ivalid result value");
    }
    
    {
        JFFJsonValidationError *error;

        BOOL result = [JFFJsonObjectValidator validateJsonObject:@[@1, @"2", @3]
                                                 withJsonPattern:@[[NSNumber class]]
                                                           error:&error];
        
        XCTAssertNotNil(error, @"error should be nil");
        XCTAssertFalse(result, @"ivalid result value");
    }
}

////// Array value tests /////

- (void)testArrayValueMatch
{
    {
        JFFJsonValidationError *error;

        BOOL result = [JFFJsonObjectValidator validateJsonObject:@[@1, @2, @3]
                                                 withJsonPattern:@[@1, @2, @3]
                                                           error:&error];

        XCTAssertNil(error, @"error should be nil");
        XCTAssertTrue(result, @"ivalid result value");
    }
    
    {
        JFFJsonValidationError *error;
        
        BOOL result = [JFFJsonObjectValidator validateJsonObject:@[]
                                                 withJsonPattern:@[]
                                                           error:&error];
        
        XCTAssertNil(error, @"error should be nil");
        XCTAssertTrue(result, @"ivalid result value");
    }

    {
        JFFJsonValidationError *error;

        BOOL result = [JFFJsonObjectValidator validateJsonObject:@[@"1"]
                                                 withJsonPattern:@[@"1"]
                                                           error:&error];

        XCTAssertNil(error, @"error should be nil");
        XCTAssertTrue(result, @"ivalid result value");
    }
}

- (void)testArrayValueMismatch
{
    {
        JFFJsonValidationError *error;

        BOOL result = [JFFJsonObjectValidator validateJsonObject:@[@1, @3]
                                                 withJsonPattern:@[@1, @2, @3]
                                                           error:&error];

        XCTAssertNotNil(error, @"error should be nil");
        XCTAssertFalse(result, @"ivalid result value");
    }

    {
        JFFJsonValidationError *error;
        
        BOOL result = [JFFJsonObjectValidator validateJsonObject:@[@""]
                                                 withJsonPattern:@[]
                                                           error:&error];
        
        XCTAssertNotNil(error, @"error should be nil");
        XCTAssertFalse(result, @"ivalid result value");
    }

    {
        JFFJsonValidationError *error;
        
        BOOL result = [JFFJsonObjectValidator validateJsonObject:@[@1]
                                                 withJsonPattern:@[@"1"]
                                                           error:&error];
        
        XCTAssertNotNil(error, @"error should be nil");
        XCTAssertFalse(result, @"ivalid result value");
    }
}

- (void)testNestedArrayObjectsMatch
{
    {
        JFFJsonValidationError *error;

        BOOL result = [JFFJsonObjectValidator validateJsonObject:@[@[@1], @[@1, @2], @[@1, @2, @3]]
                                                 withJsonPattern:@[@[[NSNumber class]]]
                                                           error:&error];

        XCTAssertNil(error, @"error should be nil");
        XCTAssertTrue(result, @"ivalid result value");
    }
    
    {
        JFFJsonValidationError *error;
        
        BOOL result = [JFFJsonObjectValidator validateJsonObject:@[@[@1, @2], @[@1, @"2"], @[@1, @2, @"3"]]
                                                 withJsonPattern:@[@[[NSNumber class]], @[@1, @"2"], @[@1, @2, [NSString class]]]
                                                           error:&error];
        
        XCTAssertNil(error, @"error should be nil");
        XCTAssertTrue(result, @"ivalid result value");
    }
}

- (void)testDictionaryMatchElements
{
    {
        JFFJsonValidationError *error;

        id nestedObject =
        @{
        @"some_num"  : @3,
        @"num_2"     : @2,
        @"some_str"  : @"str3",
        @"str_22"    : @"22",
        @"some_null" : [NSNull null],
        @"nested_ar" : @[@[@1, @2], @[@1, @"2"], @[@1, @2, @"3"]],
        };

        id object =
        @{
        @"some_num"  : @3,
        @"num_2"     : @2,
        @"some_str"  : @"str3",
        @"str_22"    : @"22",
        @"some_null" : [NSNull null],
        @"nested_ar" : @[@[@1, @2], @[@1, @"2"], @[@1, @2, @"3"]],
        @"nested_obj" : nestedObject,
        };

        BOOL result = [JFFJsonObjectValidator validateJsonObject:object
                                                 withJsonPattern:_jsonObjectPatter
                                                           error:&error];

        XCTAssertNil(error, @"error should be nil");
        XCTAssertTrue(result, @"ivalid result value");
    }
}

- (void)testDictionaryMatchNestedDictionaryElementClass
{
    {
        JFFJsonValidationError *error;
        
        id object =
        @{
        @"dict" : @{},
        };
        
        id pattern =
        @{
        @"dict" : [NSDictionary class],
        };
        
        BOOL result = [JFFJsonObjectValidator validateJsonObject:object
                                                 withJsonPattern:pattern
                                                           error:&error];
        
        XCTAssertNil(error, @"error should be nil");
        XCTAssertTrue(result, @"ivalid result value");
    }
}

- (void)testDictionaryCheckStatusCode
{
    {
        JFFJsonValidationError *error;
        
        id object =
        @{
        @"meta" : @{@"code" : @(200)},
        @"data" : @{},
        };
        
        id pattern =
        @{
        @"meta" : @{@"code" : @(200)},
        };
        
        BOOL result = [JFFJsonObjectValidator validateJsonObject:object
                                                 withJsonPattern:pattern
                                                           error:&error];
        
        XCTAssertNil(error, @"error should be nil");
        XCTAssertTrue(result, @"ivalid result value");
    }
    {
        JFFJsonValidationError *error;
        
        id object =
        @{
        @"meta" : @{@"code" : @(200)},
        @"data" : @{},
        };
        
        id pattern =
        @{
        @"meta" : @{@"code" : @(201)},
        };
        
        BOOL result = [JFFJsonObjectValidator validateJsonObject:object
                                                 withJsonPattern:pattern
                                                           error:&error];
        
        XCTAssertNotNil(error, @"error should be nil");
        XCTAssertFalse(result, @"ivalid result value");
    }
}

- (void)testDictionaryCheckOptionalKeys
{
    {
        JFFJsonValidationError *error;
        
        id object =
        @{
        @"meta" : @{@"code" : @(200)},
        };
        
        id pattern =
        @{
        @"meta" : @{@"code" : @(200)},
        jOptionalKey(@"data") : [NSDictionary class],
        };
        
        BOOL result = [JFFJsonObjectValidator validateJsonObject:object
                                                 withJsonPattern:pattern
                                                           error:&error];
        
        XCTAssertNil(error, @"error should be nil");
        XCTAssertTrue(result, @"ivalid result value");
    }
    {
        JFFJsonValidationError *error;
        
        id object =
        @{
        @"meta" : @{@"code" : @(200)},
        };
        
        id pattern =
        @{
        @"meta" : @{@"code" : @(200)},
        @"data" : [NSDictionary class],
        };
        
        BOOL result = [JFFJsonObjectValidator validateJsonObject:object
                                                 withJsonPattern:pattern
                                                           error:&error];
        
        XCTAssertNotNil(error, @"error should be nil");
        XCTAssertFalse(result, @"ivalid result value");
    }
}

- (void)testSomeSpecialStrangeCase
{
    NSString *str = @"{\"previous_cursor_str\":\"0\",\"next_cursor\":0,\"ids\":[806434819,806425640],\"previous_cursor\":0,\"next_cursor_str\":\"0\"}";
    
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                               options:0
                                                                 error:NULL];
    
    id jsonPattern = @{
    @"ids" : @[[NSNumber class]],
    };
    
    JFFJsonValidationError *error;
    
    BOOL result = [JFFJsonObjectValidator validateJsonObject:jsonObject
                                             withJsonPattern:jsonPattern
                                                       error:&error];

    XCTAssertNil(error, @"error should be nil");
    XCTAssertTrue(result, @"ivalid result value");
}

////////////////////////////////////////////////////////////////////////////////

- (void)testDictionaryMisatchElements_nested_some_num
{
    {
        JFFJsonValidationError *error;

        id nestedObject =
        @{
        @"some_num"  : @"3",
        @"num_2"     : @2,
        @"some_str"  : @"str3",
        @"str_22"    : @"22",
        @"some_null" : [NSNull null],
        @"nested_ar" : @[@[@1, @2], @[@1, @"2"], @[@1, @2, @"3"]],
        };

        id object =
        @{
        @"some_num"  : @3,
        @"num_2"     : @2,
        @"some_str"  : @"str3",
        @"str_22"    : @"22",
        @"some_null" : [NSNull null],
        @"nested_ar" : @[@[@1, @2], @[@1, @"2"], @[@1, @2, @"3"]],
        @"nested_obj" : nestedObject,
        };

        BOOL result = [JFFJsonObjectValidator validateJsonObject:object
                                                 withJsonPattern:_jsonObjectPatter
                                                           error:&error];

        XCTAssertNotNil(error, @"error should be nil");
        XCTAssertFalse(result, @"ivalid result value");
    }
}

- (void)testDictionaryMisatchElements_some_num
{
    {
        JFFJsonValidationError *error;
        
        id nestedObject =
        @{
        @"some_num"  : @3,
        @"num_2"     : @2,
        @"some_str"  : @"str3",
        @"str_22"    : @"22",
        @"some_null" : [NSNull null],
        @"nested_ar" : @[@[@1, @2], @[@1, @"2"], @[@1, @2, @"3"]],
        };
        
        id object =
        @{
        @"some_num"  : @"3",
        @"num_2"     : @2,
        @"some_str"  : @"str3",
        @"str_22"    : @"22",
        @"some_null" : [NSNull null],
        @"nested_ar" : @[@[@1, @2], @[@1, @"2"], @[@1, @2, @"3"]],
        @"nested_obj" : nestedObject,
        };

        BOOL result = [JFFJsonObjectValidator validateJsonObject:object
                                                 withJsonPattern:_jsonObjectPatter
                                                           error:&error];

        XCTAssertNotNil(error, @"error should be nil");
        XCTAssertFalse(result, @"ivalid result value");
    }
}

- (void)testDictionaryMisatchElements_hasNoProperty
{
    {
        JFFJsonValidationError *error;
        
        id object =
        @{
        @"num_22"       : @22,
        };
        
        id pattern =
        @{
        @"num_22"       : @22,
        @"required_num" : [NSNumber class],
        };
        
        BOOL result = [JFFJsonObjectValidator validateJsonObject:object
                                                 withJsonPattern:pattern
                                                           error:&error];
        
        XCTAssertNotNil(error, @"error should be nil");
        XCTAssertFalse(result, @"ivalid result value");
    }
}

////// Null value tests /////

- (void)testNullValueMatch
{
    JFFJsonValidationError *error;
    
    BOOL result = [JFFJsonObjectValidator validateJsonObject:[NSNull null]
                                             withJsonPattern:[NSNull null]
                                                       error:&error];
    
    XCTAssertNil(error, @"error should be nil");
    XCTAssertTrue(result, @"ivalid result value");
}

- (void)testNullValueMismatch
{
    JFFJsonValidationError *error;
    
    BOOL result = [JFFJsonObjectValidator validateJsonObject:[NSNull null]
                                             withJsonPattern:@(2)
                                                       error:&error];
    
    XCTAssertNotNil(error, @"error should be nil");
    XCTAssertFalse(result, @"ivalid result value");
}

- (void)testPassNilJsonPattern
{
    XCTAssertThrows( {
        [JFFJsonObjectValidator validateJsonObject:nil
                                   withJsonPattern:nil
                                             error:NULL];
    }, @"assert expected");
}

- (void)testInvalidTypeOfRootJsonObject
{
    {
        JFFJsonValidationError *error;
        
        BOOL result = [JFFJsonObjectValidator validateJsonObject:@{}
                                                 withJsonPattern:@[]
                                                           error:&error];
        
        XCTAssertFalse(result, @"NO expected");
        XCTAssertEqualObjects(error.jsonObject , @{}, @"ok");
        XCTAssertEqualObjects(error.jsonPattern, @[], @"ok");
    }
    {
        JFFJsonValidationError *error;
        
        BOOL result = [JFFJsonObjectValidator validateJsonObject:@[]
                                                 withJsonPattern:@{}
                                                           error:&error];
        
        XCTAssertFalse(result, @"NO expected");
        XCTAssertEqualObjects(error.jsonObject , @[], @"ok");
        XCTAssertEqualObjects(error.jsonPattern, @{}, @"ok");
    }
}

- (void)testValidAnyNSObjectSubclass
{
    {
        JFFJsonValidationError *error;
        
        BOOL result = [JFFJsonObjectValidator validateJsonObject:@{}
                                                 withJsonPattern:[NSObject class]
                                                           error:&error];
        
        XCTAssertTrue(result, @"NO expected");
        XCTAssertNil(error, @"ok");
    }
    {
        JFFJsonValidationError *error;
        
        BOOL result = [JFFJsonObjectValidator validateJsonObject:@[]
                                                 withJsonPattern:[NSObject class]
                                                           error:&error];
        
        XCTAssertTrue(result, @"NO expected");
        XCTAssertNil(error, @"ok");
    }
    {
        JFFJsonValidationError *error;
        
        BOOL result = [JFFJsonObjectValidator validateJsonObject:@1
                                                 withJsonPattern:[NSObject class]
                                                           error:&error];
        
        XCTAssertTrue(result, @"NO expected");
        XCTAssertNil(error, @"ok");
    }
    {
        JFFJsonValidationError *error;
        
        BOOL result = [JFFJsonObjectValidator validateJsonObject:@"1"
                                                 withJsonPattern:[NSObject class]
                                                           error:&error];
        
        XCTAssertTrue(result, @"NO expected");
        XCTAssertNil(error, @"ok");
    }
    {
        JFFJsonValidationError *error;
        
        BOOL result = [JFFJsonObjectValidator validateJsonObject:[NSNull null]
                                                 withJsonPattern:[NSObject class]
                                                           error:&error];
        
        XCTAssertTrue(result, @"NO expected");
        XCTAssertNil(error, @"ok");
    }
}

- (void)testJOptionalValue
{
    {
        JFFJsonValidationError *error;
        
        id object =
        @{
        @"region" : [NSNull new],
        };
        
        id pattern =
        @{
        @"region" : @{@"a" : [NSString class]},
        };
        
        BOOL result = [JFFJsonObjectValidator validateJsonObject:object
                                                 withJsonPattern:pattern
                                                           error:&error];
        
        XCTAssertNotNil(error, @"error should be nil");
        XCTAssertFalse(result, @"ivalid result value");
    }
    {
        JFFJsonValidationError *error;
        
        id object =
        @{
        @"region" : @{@"a" : @"b"},
        };
        
        id pattern =
        @{
        @"region" : @{@"a" : [NSString class]},
        };
        
        BOOL result = [JFFJsonObjectValidator validateJsonObject:object
                                                 withJsonPattern:pattern
                                                           error:&error];
        
        XCTAssertNil(error, @"error should be nil");
        XCTAssertTrue(result, @"ivalid result value");
    }
    {
        JFFJsonValidationError *error;
        
        id object =
        @{
        @"region" : [NSNull new],
        };
        
        id pattern =
        @{
        @"region" : jOptionalValue(@{@"a" : [NSString class]}),
        };
        
        BOOL result = [JFFJsonObjectValidator validateJsonObject:object
                                                 withJsonPattern:pattern
                                                           error:&error];
        
        XCTAssertNil(error, @"error should be nil");
        XCTAssertTrue(result, @"ivalid result value");
    }
    {
        JFFJsonValidationError *error;
        
        id object =
        @{
        @"region" : @{@"a" : @"b"},
        };
        
        id pattern =
        @{
        @"region" : jOptionalValue(@{@"a" : [NSString class]}),
        };
        
        BOOL result = [JFFJsonObjectValidator validateJsonObject:object
                                                 withJsonPattern:pattern
                                                           error:&error];
        
        XCTAssertNil(error, @"error should be nil");
        XCTAssertTrue(result, @"ivalid result value");
    }
    
    {
        JFFJsonValidationError *error;
        
        id object =
        @{
          @"balance" : @6700,
          @"bonuses" : [NSNull new],
          };
        
        id pattern =
        @{
          jOptionalKey(@"balance") : [NSNumber class],
          @"bonuses" : jOptionalValue(@{@"credits" : [NSNumber class], @"type" : [NSString class]})
          };
        
        BOOL result = [JFFJsonObjectValidator validateJsonObject:object
                                                 withJsonPattern:pattern
                                                           error:&error];
        
        XCTAssertNil(error, @"error should be nil");
        XCTAssertTrue(result, @"ivalid result value");
    }
}

@end
