#import "JFFLocationLoaderSupervisor.h"

@interface JFFLocationLoaderSupervisor () <CLLocationManagerDelegate>
@end

@implementation JFFLocationLoaderSupervisor
{
    CLLocationManager *_locationManager;
    JFFMutableAssignArray *_observers;
    CLLocationAccuracy _accuracy;
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
        _observers = [JFFMutableAssignArray new];
        
        __weak JFFLocationLoaderSupervisor *weakSelf = self;
        _observers.onRemoveObject = ^() {
            [weakSelf tryMakeLiveLonger];
        };
    }
    
    return self;
}

+ (id)sharedLocationLoaderSupervisorWithAccuracy:(CLLocationAccuracy)accuracy
{
    NSParameterAssert(accuracy == kCLLocationAccuracyHundredMeters);
    
    __weak static id instance;
    
    id result = instance;
    
    if (!instance) {
        
        result = [[self alloc] initWithAccuracy:accuracy];
        instance = result;
    }
    
    return result;
}

- (CLLocation *)location
{
    return self.locationManager.location;
}

- (void)tryMakeLiveLonger
{
    if ([_observers count] == 0)
        [self makeLiveLonger];
}

- (void)makeLiveLonger
{
    [self performSelector:@selector(doNothing) withObject:nil afterDelay:1*60.];
}

- (void)doNothing
{
}

- (CLLocationManager *)locationManager
{
    if (_locationManager)
        return _locationManager;
    
    _locationManager = [CLLocationManager new];
    _locationManager.desiredAccuracy = _accuracy;
    _locationManager.delegate = self;
    
    return _locationManager;
}

- (void)addLocationObserver:(id<JFFLocationObserver>)observer
{
    [self.locationManager startUpdatingLocation];
    
    [_observers addObject:observer];
}

- (void)removeLocationObserver:(id<JFFLocationObserver>)observer
{
    [_observers removeObject:observer];
    
    [self tryMakeLiveLonger];
}

- (void)notifyEachObserverWithLocation:(CLLocation *)newLocation
{
    NSArray *observers = [_observers array];
    for (id<JFFLocationObserver> observer in observers) {
        [observer didUpdateLocation:newLocation];
    }
}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    [self notifyEachObserverWithLocation:newLocation];
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    [self notifyEachObserverWithLocation:[locations lastObject]];
}

@end
