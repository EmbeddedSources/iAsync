@interface DevNullTest : GHTestCase
@end
 
@implementation DevNullTest

- (void)testDevNullWriteIsAllowed
{
    NSData *data = [NSData dataWithBytes:"Don't send me to /dev/null"
                                  length:26];
    
    NSError *error;
    
    BOOL result = [data writeToFile:@"/dev/null"
                            options:0
                              error:&error];
    
    GHAssertTrue(result, @"/dev/null should be supported as on any other Unix");
    GHAssertNil(error, @"/dev/null should be supported as on any other Unix");
}

- (void)testDevNullWriteIsNotAllowedWithFlags
{
    NSData *data = [NSData dataWithBytes:"Don't send me to /dev/null"
                                  length:26];
    
    NSError *error =  nil;
    
    BOOL result = [data writeToFile:@"/dev/null"
                            options:NSDataWritingAtomic | NSDataWritingFileProtectionComplete
                              error:&error];
    
    GHAssertFalse(result, @"/dev/null should be supported as on any other Unix");
    GHAssertNotNil(error, @"/dev/null should be supported as on any other Unix");
}

- (void)testNilPathProducesCrash
{
    NSData *data = [NSData dataWithBytes:"Don't send me to /dev/null"
                                  length:26];
    
    NSError *error =  nil;
    
    GHAssertThrows
    (
     [data writeToFile:nil
                options:NSDataWritingAtomic | NSDataWritingFileProtectionComplete
                  error:&error]
     , @"assert expected"
    );    
}

@end
