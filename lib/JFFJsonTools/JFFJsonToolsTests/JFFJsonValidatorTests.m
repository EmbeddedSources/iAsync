#import "JFFJsonValidatorTests.h"

#import "JFFJsonValidator.h"

#import "JFFJsonValidationError.h"

#include <objc/runtime.h>

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
    @"some_null"  : [NSString class],
    @"nested_ar"  : @[@[[NSNumber class]], @[@1, @"2"], @[@1, @2, [NSString class]]],
    };
    
    self->_jsonObjectPatter =
    @{
    @"some_num"   : [NSNumber class],
    @"num_2"      : @2,
    @"some_str"   : [NSString class],
    @"str_22"     : @"22",
    @"some_null"  : [NSString class],
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

    STAssertNil(error, @"error should be nil");
    STAssertTrue(result, @"ivalid result value");
}

- (void)testStringTypeMismatch
{
    JFFJsonValidationError *error;

    BOOL result = [JFFJsonObjectValidator validateJsonObject:[NSNumber numberWithBool:NO]
                                             withJsonPattern:[NSString class]
                                                       error:&error];

    STAssertNotNil(error, @"error should be nil");
    STAssertFalse(result, @"ivalid result value");
}

////// String value tests /////

- (void)testStringValueMatch
{
    JFFJsonValidationError *error;

    BOOL result = [JFFJsonObjectValidator validateJsonObject:@"test"
                                             withJsonPattern:@"test"
                                                       error:&error];

    STAssertNil(error, @"error should be nil");
    STAssertTrue(result, @"ivalid result value");
}

- (void)testStringValueMismatch
{
    JFFJsonValidationError *error;

    BOOL result = [JFFJsonObjectValidator validateJsonObject:@"test"
                                             withJsonPattern:@"test1"
                                                       error:&error];

    STAssertNotNil(error, @"error should be nil");
    STAssertFalse(result, @"ivalid result value");
}

////// Number type tests /////

- (void)testNumberTypeMatch
{
    JFFJsonValidationError *error;

    BOOL result = [JFFJsonObjectValidator validateJsonObject:@(1)
                                             withJsonPattern:[NSNumber class]
                                                       error:&error];

    STAssertNil(error, @"error should be nil");
    STAssertTrue(result, @"ivalid result value");
}

- (void)testNumberTypeMismatch
{
    JFFJsonValidationError *error;

    BOOL result = [JFFJsonObjectValidator validateJsonObject:@""
                                             withJsonPattern:[NSNumber class]
                                                       error:&error];

    STAssertNotNil(error, @"error should be nil");
    STAssertFalse(result, @"ivalid result value");
}

////// Number value tests /////

- (void)testNumberValueMatch
{
    JFFJsonValidationError *error;

    BOOL result = [JFFJsonObjectValidator validateJsonObject:@(2)
                                             withJsonPattern:@(2)
                                                       error:&error];

    STAssertNil(error, @"error should be nil");
    STAssertTrue(result, @"ivalid result value");
}

- (void)testNumberValueMismatch
{
    JFFJsonValidationError *error;

    BOOL result = [JFFJsonObjectValidator validateJsonObject:@(3)
                                             withJsonPattern:@(2)
                                                       error:&error];

    STAssertNotNil(error, @"error should be nil");
    STAssertFalse(result, @"ivalid result value");
}

////// Null type tests /////

- (void)testNullTypeMatch
{
    {
        JFFJsonValidationError *error;

        BOOL result = [JFFJsonObjectValidator validateJsonObject:[NSNull null]
                                                 withJsonPattern:[NSNumber class]
                                                           error:&error];

        STAssertNil(error, @"error should be nil");
        STAssertTrue(result, @"ivalid result value");
    }
    {
        JFFJsonValidationError *error;

        BOOL result = [JFFJsonObjectValidator validateJsonObject:[NSNull null]
                                                 withJsonPattern:[NSString class]
                                                           error:&error];

        STAssertNil(error, @"error should be nil");
        STAssertTrue(result, @"ivalid result value");
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

        STAssertNil(error, @"error should be nil");
        STAssertTrue(result, @"ivalid result value");
    }

    {
        JFFJsonValidationError *error;

        BOOL result = [JFFJsonObjectValidator validateJsonObject:@[@1, @2, @3]
                                                 withJsonPattern:@[[NSNumber class]]
                                                           error:&error];

        STAssertNil(error, @"error should be nil");
        STAssertTrue(result, @"ivalid result value");
    }
}

- (void)testArrayTypeMismatch
{
    {
        JFFJsonValidationError *error;

        BOOL result = [JFFJsonObjectValidator validateJsonObject:@{}
                                                 withJsonPattern:[NSArray class]
                                                           error:&error];

        STAssertNotNil(error, @"error should be nil");
        STAssertFalse(result, @"ivalid result value");
    }

    {
        JFFJsonValidationError *error;

        BOOL result = [JFFJsonObjectValidator validateJsonObject:@[@1, @"2", @3]
                                                 withJsonPattern:@[[NSNumber class]]
                                                           error:&error];

        STAssertNotNil(error, @"error should be nil");
        STAssertFalse(result, @"ivalid result value");
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

        STAssertNil(error, @"error should be nil");
        STAssertTrue(result, @"ivalid result value");
    }

    {
        JFFJsonValidationError *error;

        BOOL result = [JFFJsonObjectValidator validateJsonObject:@[]
                                                 withJsonPattern:@[]
                                                           error:&error];

        STAssertNil(error, @"error should be nil");
        STAssertTrue(result, @"ivalid result value");
    }

    {
        JFFJsonValidationError *error;

        BOOL result = [JFFJsonObjectValidator validateJsonObject:@[@"1"]
                                                 withJsonPattern:@[@"1"]
                                                           error:&error];

        STAssertNil(error, @"error should be nil");
        STAssertTrue(result, @"ivalid result value");
    }
}

- (void)testArrayValueMismatch
{
    {
        JFFJsonValidationError *error;

        BOOL result = [JFFJsonObjectValidator validateJsonObject:@[@1, @3]
                                                 withJsonPattern:@[@1, @2, @3]
                                                           error:&error];

        STAssertNotNil(error, @"error should be nil");
        STAssertFalse(result, @"ivalid result value");
    }

    {
        JFFJsonValidationError *error;

        BOOL result = [JFFJsonObjectValidator validateJsonObject:@[@""]
                                                 withJsonPattern:@[]
                                                           error:&error];

        STAssertNotNil(error, @"error should be nil");
        STAssertFalse(result, @"ivalid result value");
    }

    {
        JFFJsonValidationError *error;
        
        BOOL result = [JFFJsonObjectValidator validateJsonObject:@[@1]
                                                 withJsonPattern:@[@"1"]
                                                           error:&error];
        
        STAssertNotNil(error, @"error should be nil");
        STAssertFalse(result, @"ivalid result value");
    }
}

- (void)testNestedArrayObjectsMatch
{
    {
        JFFJsonValidationError *error;

        BOOL result = [JFFJsonObjectValidator validateJsonObject:@[@[@1], @[@1, @2], @[@1, @2, @3]]
                                                 withJsonPattern:@[@[[NSNumber class]]]
                                                           error:&error];

        STAssertNil(error, @"error should be nil");
        STAssertTrue(result, @"ivalid result value");
    }

    //TODO test nested objects
    {
        JFFJsonValidationError *error;

        BOOL result = [JFFJsonObjectValidator validateJsonObject:@[@[@1, @2], @[@1, @"2"], @[@1, @2, @"3"]]
                                                 withJsonPattern:@[@[[NSNumber class]], @[@1, @"2"], @[@1, @2, [NSString class]]]
                                                           error:&error];

        STAssertNil(error, @"error should be nil");
        STAssertTrue(result, @"ivalid result value");
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
                                                 withJsonPattern:self->_jsonObjectPatter
                                                           error:&error];

        STAssertNil(error, @"error should be nil");
        STAssertTrue(result, @"ivalid result value");
    }
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
                                                 withJsonPattern:self->_jsonObjectPatter
                                                           error:&error];

        STAssertNotNil(error, @"error should be nil");
        STAssertFalse(result, @"ivalid result value");
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
                                                 withJsonPattern:self->_jsonObjectPatter
                                                           error:&error];

        STAssertNotNil(error, @"error should be nil");
        STAssertFalse(result, @"ivalid result value");
    }
}

////// Null value tests /////

- (void)testNullValueMatch
{
    JFFJsonValidationError *error;

    BOOL result = [JFFJsonObjectValidator validateJsonObject:[NSNull null]
                                             withJsonPattern:[NSNull null]
                                                       error:&error];

    STAssertNil(error, @"error should be nil");
    STAssertTrue(result, @"ivalid result value");
}

- (void)testNullValueMismatch
{
    JFFJsonValidationError *error;

    BOOL result = [JFFJsonObjectValidator validateJsonObject:[NSNull null]
                                             withJsonPattern:@(2)
                                                       error:&error];

    STAssertNotNil(error, @"error should be nil");
    STAssertFalse(result, @"ivalid result value");
}

////// TODO 

- (void)RtestPassNilJsonPattern
{
    STAssertThrows(
    {
        [JFFJsonObjectValidator validateJsonObject:nil
                                   withJsonPattern:nil
                                             error:NULL];
    }, @"assert expected");
}

- (void)RtestInvalidTypeOfRootJsonObject
{
    {
        JFFJsonValidationError *error;

        BOOL result = [JFFJsonObjectValidator validateJsonObject:@{}
                                                 withJsonPattern:@[]
                                                           error:&error];

        STAssertFalse(result, @"NO expected");
        STAssertEqualObjects(error.jsonObject , @{}, @"ok");
        STAssertEqualObjects(error.jsonPattern, @[], @"ok");
    }
    {
        JFFJsonValidationError *error;

        BOOL result = [JFFJsonObjectValidator validateJsonObject:@[]
                                                 withJsonPattern:@{}
                                                           error:&error];

        STAssertFalse(result, @"NO expected");
        STAssertEqualObjects(error.jsonObject , @[], @"ok");
        STAssertEqualObjects(error.jsonPattern, @{}, @"ok");
    }
}

- (void)RtestJsonObjectValueMismatch
{
}

@end
