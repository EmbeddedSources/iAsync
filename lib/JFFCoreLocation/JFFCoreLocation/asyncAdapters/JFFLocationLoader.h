#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <CoreLocation/CLLocation.h>
#import <Foundation/Foundation.h>

@interface JFFLocationLoader : NSObject

//result is CLLocation object
+ (JFFAsyncOperation)locationLoaderWithAccuracy:(CLLocationAccuracy)accuracy;

@end
