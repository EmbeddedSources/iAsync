#import "JFFJsonValidatorTests.h"

#import "JFFJsonValidator.h"

#import "JFFJsonValidationError.h"

@implementation JFFJsonValidatorTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testPassNilJsonPattern
{
    STAssertThrows(
    {
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

- (void)testJsonObjectValueMismatch
{
}

@end
