#import "JFFBaseLoaderOwner.h"

#import "JFFLimitedLoadersQueue.h"

@interface JFFLimitedLoadersQueue (JFFBaseLoaderOwner)

- (void)performPendingLoaders;
- (void)didFinishedActiveLoader:(JFFBaseLoaderOwner *)activeLoader;

@end

@implementation JFFBaseLoaderOwner

+ (id)newLoaderOwnerWithLoader:(JFFAsyncOperation)loader
                         queue:(JFFLimitedLoadersQueue *)queue
{
    JFFBaseLoaderOwner *result = [self new];
    
    if (result) {
        result.loader = loader;
        result.queue  = queue;
    }
    
    return result;
}

- (void)performLoader
{
    NSParameterAssert(_cancelLoader == nil);
    
    JFFAsyncOperationProgressHandler progressCallback = ^(id progress) {
        if (_progressCallback)
            _progressCallback(progress);
    };
    
    JFFCancelAsyncOperationHandler cancelCallback = ^(BOOL canceled) {
        
        if (canceled) {
            [_queue didFinishedActiveLoader:self];
        }
        
        if (_cancelCallback) {
            JFFCancelAsyncOperationHandler cancelCallback = _cancelLoader;
            _cancelLoader = nil;
            cancelCallback(canceled);
        }
    };
    
    JFFDidFinishAsyncOperationHandler doneCallback = ^(id result, NSError *error) {
        
        [_queue didFinishedActiveLoader:self];
        
        if (_doneCallback)
            _doneCallback(result, error);
    };
    
    _cancelLoader = _loader(progressCallback, cancelCallback, doneCallback);
}

@end
