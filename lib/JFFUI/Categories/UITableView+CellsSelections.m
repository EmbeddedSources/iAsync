#import "UITableView+CellsSelections.h"

#import "UITableView+BlocksAdditions.h"

@implementation UITableView (CellsSelections)

- (void)selectAllRows
{
    [self enumerateAllIndexPaths:^(NSIndexPath *indexPath) {
        
        [self selectRowAtIndexPath:indexPath animated:NO scrollPosition:(UITableViewScrollPositionNone)];
    }];
}

- (void)deselectAllRows
{
    [self enumerateAllIndexPaths:^(NSIndexPath *indexPath) {
        
        [self deselectRowAtIndexPath:indexPath animated:NO];
    }];
}

@end
