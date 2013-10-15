#import "UITableView+CellsSelections.h"

#import "UITableView+BlocksAdditions.h"

@implementation UITableView (CellsSelections)

- (void)selectAllRowsAnimated:(BOOL)animated
{
    [self enumerateAllIndexPaths:^(NSIndexPath *indexPath) {
        
        [self selectRowAtIndexPath:indexPath animated:animated scrollPosition:(UITableViewScrollPositionNone)];
    }];
}

- (void)deselectAllRowsAnimated:(BOOL)animated
{
    [self enumerateAllIndexPaths:^(NSIndexPath *indexPath) {
        
        [self deselectRowAtIndexPath:indexPath animated:animated];
    }];
}

@end
