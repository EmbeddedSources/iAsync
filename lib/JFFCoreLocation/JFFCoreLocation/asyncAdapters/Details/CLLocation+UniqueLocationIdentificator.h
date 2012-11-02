#import <CoreLocation/CoreLocation.h>

@interface CLLocation (UniqueLocationIdentificator)

- (id<NSCopying, NSObject>)uniqueLocationIdentificator;

@end
