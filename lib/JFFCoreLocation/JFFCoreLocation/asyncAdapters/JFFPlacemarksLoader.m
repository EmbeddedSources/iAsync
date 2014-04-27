#import "JFFPlacemarksLoader.h"

#import "JFFLocationLoader.h"
#import "JFFNoPlacemarksError.h"

#import "CLLocation+UniqueLocationIdentificator.h"

//JFFLimitedLoadersQueue

static JFFLimitedLoadersQueue *sharedBalancerForPlacemarkApi()
{
    static dispatch_once_t once;
    static JFFLimitedLoadersQueue *instance;
    dispatch_once(&once, ^{
        instance = [JFFLimitedLoadersQueue new];
        instance.limitCount = 1;
    });
    return instance;
}

@interface JFFPlacemarksAsyncAdapter : NSObject<
JFFAsyncOperationInterface
>

@end

@implementation JFFPlacemarksAsyncAdapter
{
    CLLocation *_location;
    CLGeocoder *_geocoder;
}

- (instancetype)initWithLocation:(CLLocation *)location
{
    NSParameterAssert(location);
    
    self = [super init];
    
    if (self) {
        _location = location;
    }
    
    return self;
}

+ (instancetype)newPlacemarksAsyncAdapterWithLocation:(CLLocation *)location
{
    return [[self alloc] initWithLocation:location];
}

- (void)asyncOperationWithResultCallback:(JFFDidFinishAsyncOperationCallback)finishCallback
                         handlerCallback:(JFFAsyncOperationChangeStateCallback)handlerCallback
                        progressCallback:(JFFAsyncOperationProgressCallback)progressCallback
{
    finishCallback = [finishCallback copy];
    _geocoder = [CLGeocoder new];
    
    CLGeocodeCompletionHandler completionHandler = ^void(NSArray *placemarks, NSError *error) {
        
        finishCallback(placemarks, error);
    };
    
    [_geocoder reverseGeocodeLocation:_location completionHandler:completionHandler];
}

- (void)doTask:(JFFAsyncOperationHandlerTask)task
{
    NSCParameterAssert(task <= JFFAsyncOperationHandlerTaskCancel);
    if (task == JFFAsyncOperationHandlerTaskCancel) {
        [_geocoder cancelGeocode];
    }
}

@end

@implementation JFFPlacemarksLoader

+ (JFFAsyncOperation)placemarksLoaderForCurrentLocationWithAccuracy:(CLLocationAccuracy)accuracy
{
    NSParameterAssert(accuracy == kCLLocationAccuracyKilometer);
    
    JFFAsyncOperation locationLoader = [JFFLocationLoader locationLoaderWithAccuracy:accuracy];
    
    return bindSequenceOfAsyncOperations(locationLoader, ^JFFAsyncOperation(CLLocation *location) {
        
        return [self placemarksLoaderForLocation:location];
    }, nil);
}

+ (JFFAsyncOperation)placemarkLoaderForCurrentLocationWithAccuracy:(CLLocationAccuracy)accuracy
{
    NSParameterAssert(accuracy == kCLLocationAccuracyKilometer);
    
    JFFAsyncOperation locationLoader = [JFFLocationLoader locationLoaderWithAccuracy:accuracy];
    
    return bindSequenceOfAsyncOperations(locationLoader, ^JFFAsyncOperation(CLLocation *location) {
        
        return [self placemarkLoaderForLocation:location];
    }, nil);
}

+ (JFFAsyncOperation)placemarksLoaderForLocation:(CLLocation *)location
{
    JFFAsyncOperationInstanceBuilder factory = ^id< JFFAsyncOperationInterface >() {
        return [JFFPlacemarksAsyncAdapter newPlacemarksAsyncAdapterWithLocation:location];
    };
    JFFAsyncOperation loader = buildAsyncOperationWithAdapterFactory(factory);
    
    loader = [sharedBalancerForPlacemarkApi() balancedLoaderWithLoader:loader];
    
    id key = @{
    @"location" : [location uniqueLocationIdentificator],
    @"method"   : NSStringFromSelector(_cmd),
    };
    return [self asyncOperationMergeLoaders:loader withArgument:key];
}

+ (JFFAsyncOperation)placemarkLoaderForLocation:(CLLocation *)location
{
    JFFAsyncOperation placemarkLoader = [self placemarksLoaderForLocation:location];
    
    JFFAsyncOperationBinder getFirstPlacemarkOrError = ^JFFAsyncOperation(NSArray *placemarks) {
        
        if (![placemarks lastObject]) {
            
            return asyncOperationWithError([JFFNoPlacemarksError new]);
        }
        
        return asyncOperationWithResult(placemarks[0]);
    };
    
    return bindSequenceOfAsyncOperations(placemarkLoader, getFirstPlacemarkOrError, nil);
}

@end
