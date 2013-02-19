#import "JFFNoPlacemarksError.h"

@implementation JFFNoPlacemarksError

- (id)init
{
    return [self initWithDescription:NSLocalizedString(@"JFF_NO_PLACEMARK_FOR_LOCATION", nil)];
}

- (id)copyWithZone:(NSZone *)zone
{
    JFFNoPlacemarksError *copy = [super copyWithZone:zone];
    
    if (copy) {
        copy->_location = [_location copyWithZone:zone];
    }
    
    return copy;
}

@end
