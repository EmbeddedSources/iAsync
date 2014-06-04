#import "appStoreReceiptData.h"

static NSString *const mergeObject = @"2e94d46d-9f8f-4f6c-ac94-2ee1289b3c47";

@interface JFFAsyncAppStoreReceiptData : NSObject <
SKRequestDelegate,
JFFAsyncOperationInterface
>
@end

@implementation JFFAsyncAppStoreReceiptData
{
    SKReceiptRefreshRequest *_refreshReceiptRequest;
    JFFDidFinishAsyncOperationCallback _finishCallback;
}

- (void)unsubscribeFromObservervation
{
    _refreshReceiptRequest.delegate = nil;
    _refreshReceiptRequest = nil;
    _finishCallback        = nil;
}

- (void)asyncOperationWithResultCallback:(JFFDidFinishAsyncOperationCallback)finishCallback
                         handlerCallback:(JFFAsyncOperationChangeStateCallback)handlerCallback
                        progressCallback:(JFFAsyncOperationProgressCallback)progressCallback
{
    NSURL *receiptUrl = [[NSBundle mainBundle] appStoreReceiptURL];
    if ([[NSFileManager defaultManager] fileExistsAtPath:[receiptUrl path]]) {
        
        NSData *ios7ReceiptData = [NSData dataWithContentsOfURL:receiptUrl];
        if (finishCallback)
            finishCallback(ios7ReceiptData, nil);
    } else {
        
        _finishCallback = [finishCallback copy];
        
        _refreshReceiptRequest = [[SKReceiptRefreshRequest alloc] initWithReceiptProperties:@{}];
        _refreshReceiptRequest.delegate = self;
        [_refreshReceiptRequest start];
    }
}

- (void)doTask:(JFFAsyncOperationHandlerTask)task
{
    NSParameterAssert(task <= JFFAsyncOperationHandlerTaskCancel);
    
    if (task == JFFAsyncOperationHandlerTaskUnSubscribe) {
        [self unsubscribeFromObservervation];
    } else {
        [_refreshReceiptRequest cancel];
        _refreshReceiptRequest = nil;
    }
}

#pragma mark SKRequestDelegate

- (void)requestDidFinish:(SKRequest *)request
{
    if ([request isKindOfClass:[SKReceiptRefreshRequest class]]) {
        
        JFFDidFinishAsyncOperationCallback finishCallback = _finishCallback;
        
        [self unsubscribeFromObservervation];
        
        NSURL *receiptUrl = [[NSBundle mainBundle] appStoreReceiptURL];
        if ([[NSFileManager defaultManager] fileExistsAtPath:[receiptUrl path]]) {
            
            if (finishCallback)
                finishCallback([NSData dataWithContentsOfURL:receiptUrl], nil);
        } else {
            
            if (finishCallback)
                finishCallback(nil, [JFFSilentError newErrorWithDescription:@"no receipt was recieved"]);
        }
    }
}

@end

JFFAsyncOperation appStoreReceiptDataLoader(void)
{
    JFFAsyncOperationInstanceBuilder factory = ^id<JFFAsyncOperationInterface>(void) {
        return [JFFAsyncAppStoreReceiptData new];
    };
    
    JFFAsyncOperation loader = buildAsyncOperationWithAdapterFactory(factory);
    
    return [mergeObject asyncOperationMergeLoaders:loader withArgument:@(__FUNCTION__)];
}
