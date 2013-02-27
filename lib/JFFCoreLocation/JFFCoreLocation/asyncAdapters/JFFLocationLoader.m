#import "JFFLocationLoader.h"

#import "JFFLocationLoaderSupervisor.h"
#import "JFFUnableToGetLocationError.h"
#import "JFFLocationServicesDisabledError.h"

#import <JFFScheduler/JFFScheduler.h>

@interface JFFCoreLocationAsyncAdapter : NSObject<
JFFAsyncOperationInterface,
JFFLocationObserver
>

@end

@implementation JFFCoreLocationAsyncAdapter
{
    JFFLocationLoaderSupervisor *_supervisor;
    CLLocationAccuracy _accuracy;
    JFFAsyncOperationInterfaceResultHandler _handler;
    
    JFFScheduler *_scheduler;
}

- (id)initWithAccuracy:(CLLocationAccuracy)accuracy
{
    self = [super init];
    
    if (self) {
        _accuracy = accuracy;
    }
    
    return self;
}

+ (id)newCoreLocationAsyncAdapterWithAccuracy:(double)accuracyInMeters
{
    return [[self alloc] initWithAccuracy:accuracyInMeters];
}

- (void)asyncOperationWithResultHandler:(JFFAsyncOperationInterfaceResultHandler)handler
                          cancelHandler:(JFFAsyncOperationInterfaceCancelHandler)cancelHandler
                        progressHandler:(JFFAsyncOperationInterfaceProgressHandler)progress
{
    handler = [handler copy];
    _handler = handler;
    
    _supervisor = [JFFLocationLoaderSupervisor sharedLocationLoaderSupervisorWithAccuracy:_accuracy];
    
    static const NSTimeInterval twentyMinutes = 20*60;
    
    CLLocation *location = _supervisor.location;
    
    if ([location.timestamp compare:[[NSDate new] dateByAddingTimeInterval:-twentyMinutes]] == NSOrderedDescending
        && [self processLocation:location]) {
        return;
    }
    
    [_supervisor addLocationObserver:self];
    
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized) {
        
        handler(nil, [JFFLocationServicesDisabledError new]);
        return;
    }
    
    _scheduler = [JFFScheduler new];
    __weak JFFCoreLocationAsyncAdapter *weakSelf = self;
    [_scheduler addBlock:^(JFFCancelScheduledBlock cancel) {
        
        cancel();
        
        [weakSelf onSchedulerWithHandler:handler];
    } duration:1.];
}

- (void)onSchedulerWithHandler:(JFFAsyncOperationInterfaceResultHandler)handler
{
    if (_supervisor.location) {
        [self forceProcessLocation:_supervisor.location];
    } else {
        handler(nil, [JFFUnableToGetLocationError new]);
    }
}

- (void)stopObserving
{
    [_supervisor removeLocationObserver:self];
    _supervisor = nil;
}

- (void)cancel:(BOOL)canceled
{
    if (canceled) {
        [self stopObserving];
    }
}

- (void)forceProcessLocation:(CLLocation *)location
{
    NSParameterAssert(location);
    
    _handler(location, nil);
}

- (BOOL)processLocation:(CLLocation *)location
{
    if (!location)
        return NO;
    
    if (location.horizontalAccuracy <= 200.
        && location.verticalAccuracy <= 200.) {
        
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
    NSParameterAssert(accuracy == kCLLocationAccuracyHundredMeters);
    
    JFFAsyncOperationInstanceBuilder factory = ^id< JFFAsyncOperationInterface >() {
        return [JFFCoreLocationAsyncAdapter newCoreLocationAsyncAdapterWithAccuracy:accuracy];
    };
    JFFAsyncOperation loader = buildAsyncOperationWithAdapterFactory(factory);
    
    id key = @{
    @"accuracy" : @(accuracy),
    @"method"   : NSStringFromSelector(_cmd),
    @"class"    : [self description],
    };
    return [self asyncOperationMergeLoaders:loader withArgument:key];
}

@end
