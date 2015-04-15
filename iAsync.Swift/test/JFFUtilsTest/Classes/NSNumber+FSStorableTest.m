
static NSString *const fileName = @"some_number_data_to_test.data";

@interface NSNumber_FSStorableTest : GHTestCase
@end

@implementation NSNumber_FSStorableTest

- (void)clearFS
{
    NSString *docFileName = [NSString documentsPathByAppendingPathComponent:fileName];
    [[NSFileManager defaultManager] removeItemAtPath:docFileName error:NULL];
}

- (void)setUp
{
    [self clearFS];
}

- (void)tearDown
{
    [self clearFS];
}

- (void)testStorableMutableSet
{
    {
        NSNumber *number = [NSNumber newLongLongNumberWithContentsOfFile:fileName];
        
        GHAssertTrue([number longLongValue] == 0, @"ok");
        
        number = [[NSNumber alloc] initWithLongLong:10];
        [number saveNumberToFile:fileName];
    }
    {
        NSNumber *number = [NSNumber newLongLongNumberWithContentsOfFile:fileName];
        
        GHAssertTrue([number longLongValue] == 10, @"ok");
    }
}

@end
