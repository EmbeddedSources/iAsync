#import <Foundation/Foundation.h>

@class CLLocation;

@protocol JFFLocationObserver <NSObject>

@required
- (void)didUpdateLocation:(CLLocation *)newLocation;

@end

@interface JFFLocationLoaderSupervisor : NSObject

@property(readonly, nonatomic) CLLocation *location;

+ (id)sharedLocationLoaderSupervisorWithAccuracy:(CLLocationAccuracy)accuracy;

- (void)addLocationObserver:(id<JFFLocationObserver>)observer;
- (void)removeLocationObserver:(id<JFFLocationObserver>)observer;

@end
