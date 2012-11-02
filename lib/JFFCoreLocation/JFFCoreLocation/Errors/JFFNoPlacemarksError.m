#import "JFFNoPlacemarksError.h"

@implementation JFFNoPlacemarksError

- (id)init
{
    return [self initWithDescription:NSLocalizedString(@"JFF_NO_PLACEMARK_FOR_LOCATION", nil)];
}

- (id)copyWithZone:(NSZone *)zone
{
    JFFNoPlacemarksError *copy = [[[self class] allocWithZone:zone] init];
    
    if (copy) {
        copy->_location = [self->_location copyWithZone:zone];
    }
    
    return copy;
}

@end
