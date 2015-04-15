#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@class CLLocation;

@interface JFFPlacemarksLoader : NSObject

//result is NSArray of CLPlacemark objects
+ (JFFAsyncOperation)placemarksLoaderForCurrentLocationWithAccuracy:(CLLocationAccuracy)accuracy;

//result is CLPlacemark objects
+ (JFFAsyncOperation)placemarkLoaderForCurrentLocationWithAccuracy:(CLLocationAccuracy)accuracy;

//result is NSArray of CLPlacemark objects
+ (JFFAsyncOperation)placemarksLoaderForLocation:(CLLocation *)location;

//result is CLPlacemark object
+ (JFFAsyncOperation)placemarkLoaderForLocation:(CLLocation *)location;

@end
