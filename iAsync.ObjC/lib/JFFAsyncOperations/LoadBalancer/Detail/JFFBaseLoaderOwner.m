#import "JFFBaseLoaderOwner.h"

#import "JFFLimitedLoadersQueue.h"

@interface JFFLimitedLoadersQueue (JFFBaseLoaderOwner)

- (void)performPendingLoaders;
- (void)didFinishActiveLoader:(JFFBaseLoaderOwner *)activeLoader;

@end

@implementation JFFBaseLoaderOwner

+ (instancetype)newLoaderOwnerWithLoader:(JFFAsyncOperation)loader
                                   queue:(JFFLimitedLoadersQueue *)queue
{
    JFFBaseLoaderOwner *result = [self new];
    
    if (result) {
        result->_loader = [loader copy];
        result->_queue  = queue;
    }
    
    return result;
}

- (void)clear
{
    _loader           = nil;
    _queue            = nil;
    _loadersHandler   = nil;
    _progressCallback = nil;
    _stateCallback    = nil;
    _doneCallback     = nil;
}

- (void)performLoader
{
    NSParameterAssert(_loadersHandler == nil);
    
    JFFAsyncOperationProgressCallback progressCallback = ^(id progress) {
        
        if (_progressCallback)
            _progressCallback(progress);
    };
    
    JFFAsyncOperationChangeStateCallback stateCallback = ^(JFFAsyncOperationState state) {
        
        if (_stateCallback)
            _stateCallback(state);
    };
    
    JFFDidFinishAsyncOperationCallback doneCallback = ^(id result, NSError *error) {
        
        [_queue didFinishActiveLoader:self];
        
        if (_doneCallback)
            _doneCallback(result, error);
        
        [self clear];
    };
    
    _loadersHandler = _loader(progressCallback, stateCallback, doneCallback);
}

@end
