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
    NSData *data_ = [NSData dataWithBytes:"Don't send me to /dev/null"
                                   length:26];
    
    NSError* error_ =  nil;
    
    BOOL result_ = [data_ writeToFile:@"/dev/null"
                              options:NSDataWritingAtomic | NSDataWritingFileProtectionComplete
                                error:&error_];
    
    GHAssertFalse(result_, @"/dev/null should be supported as on any other Unix");
    GHAssertNotNil(error_, @"/dev/null should be supported as on any other Unix");
}

- (void)testNilPathProducesCrash
{
    NSData *data_ = [NSData dataWithBytes:"Don't send me to /dev/null"
                                   length:26];
    
    NSError* error_ =  nil;
    
    GHAssertThrows
    (
     [data_ writeToFile:nil
                options:NSDataWritingAtomic | NSDataWritingFileProtectionComplete
                  error:&error_]
     , @"assert expected"
    );    
}

@end
