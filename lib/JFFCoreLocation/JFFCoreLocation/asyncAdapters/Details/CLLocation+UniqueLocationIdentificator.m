#import "CLLocation+UniqueLocationIdentificator.h"

@implementation CLLocation (UniqueLocationIdentificator)

- (id<NSCopying, NSObject>)uniqueLocationIdentificator
{
    return @[@(self.coordinate.latitude), @(self.coordinate.longitude)];
}

@end
