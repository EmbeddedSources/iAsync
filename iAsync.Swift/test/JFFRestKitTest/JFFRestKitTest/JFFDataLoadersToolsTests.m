#import <JFFTestTools/JFFTestTools.h>

static JFFAsyncOperation testDataLoader(const int *buffer, int bufferSize)
{
    return ^JFFAsyncOperationHandler(JFFAsyncOperationProgressCallback progressCallback,
                                     JFFAsyncOperationChangeStateCallback cancelCallback,
                                     JFFDidFinishAsyncOperationCallback doneCallback) {
        
        __block JFFTimer *timer = [JFFTimer new];
        
        __block NSUInteger dataIndex = 0;
        
        [timer addBlock:^(JFFCancelScheduledBlock cancel) {
            
            if (dataIndex == bufferSize) {
                
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                timer = nil;
#pragma clang diagnostic pop
                
                cancel();
                
                if (doneCallback)
                    doneCallback([NSNull new], nil);
            } else {
                
                const void *ptr = &buffer[dataIndex];
                NSData *data = [NSData dataWithBytesNoCopy:(void *)ptr length:sizeof(int)];
                dataIndex += 1;
                
                if (progressCallback)
                    progressCallback(data);
            }
        } duration:.01];
        
        return ^(JFFAsyncOperationHandlerTask task) {
            
            NSCParameterAssert(task <= JFFAsyncOperationHandlerTaskCancel);
            
            if (!timer)
                return;
            
            if (cancelCallback)
                cancelCallback(task);
            
            [timer cancelAllScheduledOperations];
            timer = nil;
        };
    };
}

@interface JFFDataLoadersToolsTests : GHTestCase
@end

@implementation JFFDataLoadersToolsTests

- (void)setUp
{
}

- (void)tearDown
{
}

- (void)testJTmpFileLoaderWithChunkedDataLoader
{
    static const int data[] = {0, 1, 2, 22, 45};
    
    NSMutableArray *chunks = [NSMutableArray new];
    
    __block NSString *filePath;
    
    void (^block)(JFFSimpleBlock) = ^(JFFSimpleBlock block) {
        
        JFFAsyncOperation dataLoader = testDataLoader(data, sizeof(data)/sizeof(data[0]));
        
        JFFAsyncOperation loader = jTmpFileLoaderWithChunkedDataLoader(dataLoader);
        
        JFFAsyncOperationProgressCallback progressCallback = ^(NSData *chunkData) {
            
            [chunks addObject:chunkData];
        };
        
        loader(progressCallback, nil, ^(id result, NSError *error) {
            
            filePath = result;
            block();
        });
    };
    
    performAsyncRequestOnMainThreadWithBlock(block, 10.);
    
    NSData *expectedResultData = [NSData dataWithBytesNoCopy:(void *)data length:sizeof(data)];
    NSData *resultData = [NSData dataWithContentsOfFile:filePath];
    GHAssertEqualObjects(expectedResultData, resultData, nil);
    
    NSMutableArray *expectedChunks = [NSMutableArray arrayWithSize:sizeof(data)/sizeof(data[0])
                                                          producer:^id(NSUInteger index) {
                                                              
                                                              const void *ptr = &data[index];
                                                              NSData *data = [NSData dataWithBytesNoCopy:(void *)ptr length:sizeof(int)];
                                                              return data;
                                                          }];
    
    GHAssertEqualObjects(expectedChunks, chunks, nil);
}

@end
