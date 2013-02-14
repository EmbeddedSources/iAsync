#import "JFFResponseDataWithUpdateData.h"

@implementation JFFResponseDataWithUpdateData

- (id)copyWithZone:(NSZone *)zone
{
    JFFResponseDataWithUpdateData *copy = [[[self class] allocWithZone:zone] init];
    
    if (copy) {
        copy->_data       = [self->_data       copyWithZone:zone];
        copy->_updateDate = [self->_updateDate copyWithZone:zone];
    }
    
    return copy;
}

@end