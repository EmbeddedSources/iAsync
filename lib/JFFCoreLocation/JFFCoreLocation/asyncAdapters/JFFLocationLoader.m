#import "JFFLocationLoader.h"

#import "JFFUnableToGetLocationError.h"
#import "JFFLocationServicesDisabledError.h"

#import <JFFScheduler/JFFScheduler.h>

@interface JFFCoreLocationAsyncAdapter : NSObject<
JFFAsyncOperationInterface,
CLLocationManagerDelegate
>

@end

@implementation JFFCoreLocationAsyncAdapter
{
    CLLocationManager *_locationManager;//TODO use shared location manager !!!
    CLLocationAccuracy _accuracy;
    
    JFFAsyncOperationInterfaceHandler _handler;
    
    JFFScheduler *_scheduler;
}

- (void)dealloc
{
    [_locationManager stopUpdatingLocation];
    _locationManager.delegate = nil;
    _locationManager = nil;
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

- (void)asyncOperationWithResultHandler:(JFFAsyncOperationInterfaceHandler)handler
                        progressHandler:(JFFAsyncOperationInterfaceProgressHandler)progress
{
    //TODO prompt message about using location service as soon as possible
    if (![CLLocationManager locationServicesEnabled]) {
        
        handler(nil, [JFFLocationServicesDisabledError new]);
        return;
    }
    
    handler = [handler copy];
    _handler = handler;
    
    CLLocationManager *locationManager = [CLLocationManager new];
    _locationManager = locationManager;
    _locationManager.desiredAccuracy = _accuracy;
    
    static const NSTimeInterval twentyMinutes = 20*60;
    
    CLLocation *location = _locationManager.location;
    
    if ([location.timestamp compare:[[NSDate new] dateByAddingTimeInterval:-twentyMinutes]] == NSOrderedDescending
        && [self processLocation:_locationManager.location]) {
        return;
    }
    
    _locationManager.delegate = self;
    [_locationManager startUpdatingLocation];
    
    __weak JFFCoreLocationAsyncAdapter *weakSelf = self;
    [_scheduler addBlock:^(JFFCancelScheduledBlock cancel) {
        
        cancel();
        
        if (locationManager.location) {
            [weakSelf forceProcessLocation:locationManager.location];
        } else {
            handler(nil, [JFFUnableToGetLocationError new]);
        }
    } duration:1.];
}

- (void)cancel:(BOOL)canceled
{
    if (canceled) {
        [_locationManager stopUpdatingLocation];
        _locationManager = nil;
    }
}

#pragma mark CLLocationManagerDelegate

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
    }
    
    return YES;
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    [self processLocation:newLocation];
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    [self processLocation:[locations lastObject]];
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
    @"method"   : @"locationLoaderWithAccuracy",
    @"class"    : @"JFFLocationLoader",
    };
    return [NSObject asyncOperationMergeLoaders:loader withArgument:key];
}

@end
