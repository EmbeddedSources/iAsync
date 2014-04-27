
#import <JFFAsyncOperations/Helpers/JFFDidFinishAsyncOperationBlockHolder.h>
#import <JFFAsyncOperations/JFFBlockOperation.h>

@interface ParalelBlockTest : GHAsyncTestCase
@end

@implementation ParalelBlockTest

- (void)setUp
{
    [JFFBlockOperation enableInstancesCounting];
}

- (void)testParalelTask
{
    const NSUInteger initialSchedulerInstancesCount = [JFFBlockOperation instancesCount];
    
    __block BOOL theSameThread = NO;
    __block BOOL theProgressOk = NO;
    
    void (^block)(JFFSimpleBlock) = ^(JFFSimpleBlock complete) {
        
        @autoreleasepool
        {
            dispatch_queue_t currentQueue = dispatch_get_current_queue();
            
            JFFSyncOperationWithProgress progressLoadDataBlock = ^id(NSError** error,
                                                                     JFFAsyncOperationProgressCallback progressCallback) {
                
                if (progressCallback)
                    progressCallback([NSNull null]);
                return [NSNull null];
            };
            JFFAsyncOperation loader = asyncOperationWithSyncOperationWithProgressBlock(progressLoadDataBlock);
            
            JFFDidFinishAsyncOperationCallback doneCallback = ^(id result, NSError *error)
            {
                theSameThread = ( currentQueue == dispatch_get_current_queue() );
                
                if ( result && theSameThread )
                {
                    complete();
                }
                else
                {
                    complete();
                }
            };
            
            JFFAsyncOperationProgressCallback progressCallback = ^(id data)
            {
                theProgressOk = YES;
                
                theSameThread = (currentQueue == dispatch_get_current_queue());
                
                if (!theSameThread) {
                    
                    complete();
                }
            };
            
            loader(progressCallback, nil, doneCallback);
        }
    };
    
    [self performAsyncRequestOnMainThreadWithBlock:block
                                          selector:_cmd
                                           timeout:1.];
    
    GHAssertTrue(initialSchedulerInstancesCount == [JFFBlockOperation instancesCount], @"OK");
    
    GHAssertTrue(theSameThread, @"OK");
    GHAssertTrue(theProgressOk, @"OK");
}

- (void)testCancelParalelTask
{
    const NSUInteger initialSchedulerInstancesCount = [JFFBlockOperation instancesCount];
    
    __block BOOL theSameThread = NO;
    
    void (^block)(JFFSimpleBlock) = ^(JFFSimpleBlock complete) {
        @autoreleasepool
        {
            dispatch_queue_t currentQueue = dispatch_get_current_queue();
            
            JFFSyncOperationWithProgress progressLoadDataBlock = ^id(NSError **error,
                                                                     JFFAsyncOperationProgressCallback progressCallback) {
                
                progressCallback([ NSNull new]);
                return [NSNull new];
            };
            JFFAsyncOperation loader = asyncOperationWithSyncOperationWithProgressBlock(progressLoadDataBlock);
            
            JFFAsyncOperationChangeStateCallback stateCallback = ^(JFFAsyncOperationState state)
            {
                complete();
            };
            
            JFFDidFinishAsyncOperationCallback doneCallback = ^(id result, NSError *error)
            {
                theSameThread = (currentQueue == dispatch_get_current_queue());
                
                complete();
            };
            
            JFFAsyncOperationProgressCallback progressCallback = ^(id data) {
                
                complete();
            };
            
            asyncOperationWithDelay(0.1, 0.01)(nil, nil, ^(id result, NSError *error)
            {
                loader(progressCallback,
                       stateCallback,
                       doneCallback)(YES);
            } );
        }
    };
    
    [self performAsyncRequestOnMainThreadWithBlock:block
                                          selector:_cmd
                                           timeout:1.];
    
    GHAssertTrue(initialSchedulerInstancesCount == [JFFBlockOperation instancesCount], @"OK");
    
    GHAssertTrue(theSameThread, @"OK");
}

@end
