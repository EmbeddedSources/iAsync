
static NSString *const fileName = @"some_set_data_to_test.data";

@interface NSMutableSet_StorableSetTest : GHTestCase
@end

@implementation NSMutableSet_StorableSetTest

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
        NSMutableSet *set = [NSMutableSet newStorableSetWithContentsOfFile:fileName];
        
        GHAssertTrue([set count] == 0, @"ok");
        
        GHAssertTrue([set addAndSaveObject:@"a"], @"ok");
    }
    {
        NSMutableSet *set = [NSMutableSet newStorableSetWithContentsOfFile:fileName];
        
        GHAssertTrue([set count] == 1, @"ok");
        GHAssertEqualObjects([[NSSet alloc] initWithArray:@[@"a"]], set, @"ok");
        GHAssertTrue([set removeAndSaveObject:@"a"], @"ok");
    }
    {
        NSMutableSet *set = [NSMutableSet newStorableSetWithContentsOfFile:fileName];
        
        GHAssertTrue([set count] == 0, @"ok");
    }
}

@end
