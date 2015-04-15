#import "JFFLocationLoader.h"

#import "JFFLocationLoaderSupervisor.h"
#import "JFFUnableToGetLocationError.h"
#import "JFFLocationServicesDisabledError.h"

#import <JFFScheduler/JFFTimer.h>

@interface JFFCoreLocationAsyncAdapter : NSObject<
JFFAsyncOperationInterface,
JFFLocationObserver
>

@end

@implementation JFFCoreLocationAsyncAdapter
{
@public
    NSTimeInterval _tolerance;
@private
    JFFLocationLoaderSupervisor *_supervisor;
    CLLocationAccuracy _accuracy;
    JFFDidFinishAsyncOperationCallback _finishCallback;
    
    JFFTimer *_timer;
}

- (instancetype)initWithAccuracy:(CLLocationAccuracy)accuracy
{
    self = [super init];
    
    if (self) {
        _accuracy = accuracy;
    }
    
    return self;
}

+ (instancetype)newCoreLocationAsyncAdapterWithAccuracy:(double)accuracyInMeters
{
    return [[self alloc] initWithAccuracy:accuracyInMeters];
}

- (void)asyncOperationWithResultCallback:(JFFDidFinishAsyncOperationCallback)finishCallback
                         handlerCallback:(JFFAsyncOperationChangeStateCallback)handlerCallback
                        progressCallback:(JFFAsyncOperationProgressCallback)progressCallback
{
    finishCallback = [finishCallback copy];
    _finishCallback = finishCallback;
    
    _supervisor = [JFFLocationLoaderSupervisor sharedLocationLoaderSupervisorWithAccuracy:_accuracy];
    
    static const NSTimeInterval twentyMinutes = 20*60;
    
    CLLocation *location = _supervisor.location;
    
    if ([location.timestamp compare:[[NSDate new] dateByAddingTimeInterval:-twentyMinutes]] == NSOrderedDescending
        && [self processLocation:location]) {
        return;
    }
    
    [_supervisor addLocationObserver:self];
    
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized) {
        
        finishCallback(nil, [JFFLocationServicesDisabledError new]);
        return;
    }
    
    _timer = [JFFTimer new];
    __weak JFFCoreLocationAsyncAdapter *weakSelf = self;
    [_timer addBlock:^(JFFCancelScheduledBlock cancel) {
        
        cancel();
        
        [weakSelf onSchedulerWithHandler:finishCallback];
    } duration:_tolerance];
}

- (void)onSchedulerWithHandler:(JFFDidFinishAsyncOperationCallback)finishCallback
{
    if (_supervisor.location) {
        [self forceProcessLocation:_supervisor.location];
    } else {
        finishCallback(nil, [JFFUnableToGetLocationError new]);
    }
}

- (void)stopObserving
{
    [_supervisor removeLocationObserver:self];
    _supervisor = nil;
}

- (void)doTask:(JFFAsyncOperationHandlerTask)task
{
    NSParameterAssert(task <= JFFAsyncOperationHandlerTaskCancel);
    
    if (task == JFFAsyncOperationHandlerTaskCancel) {
        [self stopObserving];
    }
}

- (void)forceProcessLocation:(CLLocation *)location
{
    NSParameterAssert(location);
    
    _finishCallback(location, nil);
}

- (BOOL)processLocation:(CLLocation *)location
{
    if (!location)
        return NO;
    
    if (location.horizontalAccuracy <= 2000.
        && location.verticalAccuracy <= 2000.) {
        
        [self forceProcessLocation:location];
        return YES;
    }
    
    return NO;
}

#pragma mark JFFLocationObserver

- (void)didUpdateLocation:(CLLocation *)newLocation
{
    [self processLocation:newLocation];
}

@end

@implementation JFFLocationLoader

+ (JFFAsyncOperation)locationLoaderWithAccuracy:(CLLocationAccuracy)accuracy
{
    return [self locationLoaderWithAccuracy:accuracy tolerance:3.];
}

+ (JFFAsyncOperation)locationLoaderWithAccuracy:(CLLocationAccuracy)accuracy tolerance:(NSTimeInterval)tolerance
{
    NSParameterAssert(accuracy == kCLLocationAccuracyKilometer);
    
    JFFAsyncOperationInstanceBuilder factory = ^id<JFFAsyncOperationInterface>(void) {
        
        JFFCoreLocationAsyncAdapter *result = [JFFCoreLocationAsyncAdapter newCoreLocationAsyncAdapterWithAccuracy:accuracy];
        result->_tolerance = tolerance;
        return result;
    };
    JFFAsyncOperation loader = buildAsyncOperationWithAdapterFactory(factory);
    
    id key = @{
    @"accuracy" : @(accuracy),
    @"method"   : NSStringFromSelector(_cmd),
    };
    return [self asyncOperationMergeLoaders:loader withArgument:key];
}

@end
