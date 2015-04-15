#import "ArrayLoadersMerger.h"

#import "JFFAsyncOperationHelpers.h"
#import "JFFAsyncOperationContinuity.h"

//Errors
#import "JFFAsyncOpFinishedByCancellationError.h"
#import "JFFAsyncOpFinishedByUnsubscriptionError.h"

#import "NSObject+AsyncPropertyReader.h"

@interface ArrayLoadersMerger ()

@property (nonatomic, copy) JFFArrayOfObjectsLoader arrayOfObjectsLoader;
@property (nonatomic) NSMutableArray *activeArrayLoaders;

@end

@interface JFFLoadersCallbacksData : NSObject

@property (nonatomic, copy) JFFAsyncOperationProgressCallback progressCallback;
@property (nonatomic, copy) JFFAsyncOperationChangeStateCallback stateCallback;
@property (nonatomic, copy) JFFDidFinishAsyncOperationCallback doneCallback;

@property (nonatomic) BOOL suspended;

- (void)unsubscribe;

@end

@implementation JFFLoadersCallbacksData

- (void)unsubscribe
{
    _progressCallback = nil;
    _stateCallback    = nil;
    _doneCallback     = nil;
}

@end

@interface ActiveArrayLoader : NSObject

@property (nonatomic) NSMutableDictionary *loadersCallbacksByKey;
@property (nonatomic, readonly) NSArray *keys;
@property (nonatomic, readonly, copy) JFFAsyncOperation loader;

@end

@implementation ActiveArrayLoader
{
    __weak ArrayLoadersMerger *_owner;
    JFFAsyncOperation        _nativeLoader;
    JFFAsyncOperationHandler _nativeHandler;
}

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithOwner:(ArrayLoadersMerger *)owner
        loadersCallbacksByKey:(NSMutableDictionary *)loadersCallbacksByKey
{
    self = [super init];
    
    if (self) {
        _owner                 = owner;
        _loadersCallbacksByKey = loadersCallbacksByKey;
    }
    
    return self;
}

+ (instancetype)newActiveArrayLoaderWithOwner:(ArrayLoadersMerger *)owner
                        loadersCallbacksByKey:(NSMutableDictionary *)loadersCallbacksByKey
{
    return [[self alloc] initWithOwner:owner
                 loadersCallbacksByKey:loadersCallbacksByKey];
}

- (JFFAsyncOperation)loader
{
    return _nativeLoader;
}

- (void)runLoader
{
    NSParameterAssert(_nativeLoader == nil);
    
    _keys = [_loadersCallbacksByKey allKeys];
    
    JFFAsyncOperation loader = [_owner arrayOfObjectsLoader](_keys);
    
    __weak ActiveArrayLoader *weakSelf = self;
    
    loader = ^JFFAsyncOperationHandler(JFFAsyncOperationProgressCallback progressCallback,
                                       JFFAsyncOperationChangeStateCallback stateCallback,
                                       JFFDidFinishAsyncOperationCallback doneCallback) {
        
        JFFAsyncOperationProgressCallback progressCallbackWrapper = ^(id progressInfo) {
            
            ActiveArrayLoader *self_ = weakSelf;
            if (self_) {
                [self_->_loadersCallbacksByKey enumerateKeysAndObjectsUsingBlock:^(id key, JFFLoadersCallbacksData *callbacks, BOOL *stop) {
                    callbacks.progressCallback(progressInfo);
                }];
            }
            
            if (progressCallback)
                progressCallback(progressInfo);
        };
        JFFAsyncOperationChangeStateCallback stateCallbackWrapper = ^(JFFAsyncOperationState state) {
            
            ActiveArrayLoader *self_ = weakSelf;
            if (self_) {
                [self_->_loadersCallbacksByKey enumerateKeysAndObjectsUsingBlock:^(id key, JFFLoadersCallbacksData *callbacks, BOOL *stop) {
                    callbacks.stateCallback(state);
                }];
            }
            
            if (stateCallback)
                stateCallback(state);
        };
        JFFDidFinishAsyncOperationCallback doneCallbackWrapper = ^(NSArray *results, NSError *error) {
            
            ActiveArrayLoader *self_ = weakSelf;
            if (self_) {
                
                NSDictionary *loadersCallbacksByKey = self_->_loadersCallbacksByKey;
                [self_ clearState];
                
                [loadersCallbacksByKey enumerateKeysAndObjectsUsingBlock:^(id key, JFFLoadersCallbacksData *callbacks, BOOL *stop) {
                    id result = results?results[[self_.keys indexOfObject:key]]:nil;
                    
                    callbacks.doneCallback(result, error);
                    
                    callbacks.doneCallback     = nil;
                    callbacks.progressCallback = nil;
                    callbacks.stateCallback    = nil;
                }];
            }
            
            if (doneCallback)
                doneCallback(results, error);
        };
        
        return loader(progressCallbackWrapper, stateCallbackWrapper, doneCallbackWrapper);
    };
    
    _nativeLoader = [self asyncOperationMergeLoaders:loader withArgument:_keys];
    _nativeHandler = _nativeLoader(nil, nil, nil);
}

- (void)cancelLoader
{
    if (!_nativeHandler)
        return;
    
    ActiveArrayLoader *self_ = self;
    
    JFFAsyncOperationHandler nativeHandler = self_->_nativeHandler;
    [self_ clearState];
    nativeHandler(JFFAsyncOperationHandlerTaskCancel);
}

- (void)clearState
{
    _loadersCallbacksByKey = nil;
    [_owner.activeArrayLoaders removeObject:self];
    _nativeHandler = nil;
    _nativeLoader  = nil;
}

@end

@implementation ArrayLoadersMerger
{
    NSMutableDictionary *_pendingLoadersCallbacksByKey;
}

- (instancetype)initWithArrayOfObjectsLoader:(JFFArrayOfObjectsLoader)arrayOfObjectsLoader
{
    self = [super init];
    
    if (self) {
        _arrayOfObjectsLoader = [arrayOfObjectsLoader copy];
    }
    
    return self;
}

+ (instancetype)newArrayLoadersMergerWithArrayOfObjectsLoader:(JFFArrayOfObjectsLoader)arrayOfObjectsLoader
{
    return [[self alloc] initWithArrayOfObjectsLoader:arrayOfObjectsLoader];
}

- (ActiveArrayLoader *)currentLoaderForKey:(id<NSCopying, NSObject>)key
{
    ActiveArrayLoader *result = [_activeArrayLoaders firstMatch:^BOOL(ActiveArrayLoader *object) {
        return object.loadersCallbacksByKey[key];
    }];
    return result;
}

- (JFFAsyncOperation)oneObjectLoaderForKey:(id<NSCopying, NSObject>)key
{
    ActiveArrayLoader *currentLoader = [self currentLoaderForKey:key];
    
    if (currentLoader) {
        
        NSUInteger resultIndex = [currentLoader.keys indexOfObject:key];
        
        JFFAsyncOperation loader = bindSequenceOfAsyncOperations(currentLoader.loader, ^JFFAsyncOperation(NSArray *result) {
            //TODO check length of result
            return asyncOperationWithResult(result[resultIndex]);
        }, nil);
        
        return loader;
    }
    
    JFFAsyncOperation loader = ^JFFAsyncOperationHandler(JFFAsyncOperationProgressCallback progressCallback,
                                                         JFFAsyncOperationChangeStateCallback stateCallback,
                                                         JFFDidFinishAsyncOperationCallback doneCallback) {
        
        JFFLoadersCallbacksData *callbacks = [JFFLoadersCallbacksData new];
        callbacks.progressCallback = progressCallback;
        callbacks.stateCallback    = stateCallback;
        callbacks.doneCallback     = doneCallback;
        
        if (!_pendingLoadersCallbacksByKey)
            _pendingLoadersCallbacksByKey = [NSMutableDictionary new];
        
        _pendingLoadersCallbacksByKey[key] = callbacks;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self runLoadingOfPendingKeys];
        });
        
        return ^(JFFAsyncOperationHandlerTask task) {
            
            switch (task) {
                case JFFAsyncOperationHandlerTaskUnSubscribe:
                {
                    if (doneCallback)
                        doneCallback(nil, [JFFAsyncOpFinishedByUnsubscriptionError new]);
                    break;
                }
                case JFFAsyncOperationHandlerTaskCancel:
                {
                    if (_pendingLoadersCallbacksByKey[key]) {
                        [_pendingLoadersCallbacksByKey removeObjectForKey:key];
                        if (doneCallback)
                            doneCallback(nil, [JFFAsyncOpFinishedByCancellationError new]);
                    } else {
                        ActiveArrayLoader *currentLoader = [self currentLoaderForKey:key];
                        [currentLoader cancelLoader];
                    }
                    break;
                }
                case JFFAsyncOperationHandlerTaskResume:
                {
                    NSParameterAssert(@"unsupported parameter: JFFAsyncOperationHandlerTaskResume");
                    break;
                }
                case JFFAsyncOperationHandlerTaskSuspend:
                {
                    NSParameterAssert(@"unsupported parameter: JFFAsyncOperationHandlerTaskSuspend");
                    break;
                }
                default:
                {
                    NSParameterAssert(([[NSString alloc] initWithFormat:@"invalid parameter: %lld", (unsigned long long)task]));
                    break;
                }
            }
        };
    };
    
    return [self asyncOperationMergeLoaders:loader withArgument:key];
}

- (void)runLoadingOfPendingKeys
{
    if ([_pendingLoadersCallbacksByKey count] == 0)
        return;
    
    ActiveArrayLoader *loader = [ActiveArrayLoader newActiveArrayLoaderWithOwner:self
                                                           loadersCallbacksByKey:_pendingLoadersCallbacksByKey];
    
    if (!_activeArrayLoaders)
        _activeArrayLoaders = [NSMutableArray new];
    
    [_activeArrayLoaders addObject:loader];
    
    _pendingLoadersCallbacksByKey = nil;
    
    [loader runLoader];
}

@end
