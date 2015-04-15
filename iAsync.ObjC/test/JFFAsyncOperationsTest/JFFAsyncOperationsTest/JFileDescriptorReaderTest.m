
@interface JFileDescriptorReaderTest : GHAsyncTestCase
@end

@implementation JFileDescriptorReaderTest
{
    NSData *_data;
    NSString *_filePath;
}

- (void)prepareDataFile
{
    if (_data)
        return;
    
    srand(0);
    
    size_t size = sizeof(int);
    
    NSMutableData *data = [NSMutableData new];
    
    //1000000
    
    for (NSUInteger index = 0; index < 10; ++index) {
        
        int value = rand();
        [data appendBytes:&value length:size];
    }
    
    _data = [data copy];
    
    NSString *fileName = [[NSUUID new] UUIDString];
    _filePath = [NSString cachesPathByAppendingPathComponent:fileName];
    
    [_data writeToFile:_filePath atomically:YES];
}

- (void)setUp
{
    [self prepareDataFile];
}

- (void)testJFileDescriptorReaderDownloadFullFileAndTestContent
{
    NSMutableData *expectedData = [NSMutableData new];
    
    void (^block)(JFFSimpleBlock) = ^void(JFFSimpleBlock complete) {
        
        JFFFileHendlerBuilder handleBuilder = ^uintptr_t() {
            
            return open([_filePath UTF8String], (O_RDONLY | O_NONBLOCK));
        };
        
        JFFAsyncOperation loader = jFileDescriptorReader(handleBuilder, dispatch_get_main_queue());
        
        JFFAsyncOperationProgressCallback progressCallback = ^(NSData *chunk) {
            
            [expectedData appendData:chunk];
        };
        
        loader(progressCallback, nil, ^(id result, NSError *error) {
            
            complete();
        });
    };
    
    [self performAsyncRequestOnMainThreadWithBlock:block
                                          selector:_cmd
                                           timeout:10000.];
    
    GHAssertEqualObjects(expectedData, _data, nil);
}

@end
