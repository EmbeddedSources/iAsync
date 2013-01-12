#import "JFFNoManagedObjectError.h"

@implementation JFFNoManagedObjectError

- (id)init
{
    return [self initWithDescription:NSLocalizedString(@"JFF_MANAGED_OBJECT_WAS_DELETED", nil)];
}

@end
