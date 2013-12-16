#import "UITableView+WithinUpdates.h"

@implementation UITableView (WithinUpdates)

- (void)withinUpdates:(void (^)(void))block
{
    [self beginUpdates];
    
    @try
    {
        block();
    }
    @finally
    {
        [self endUpdates];
    }
}

@end
