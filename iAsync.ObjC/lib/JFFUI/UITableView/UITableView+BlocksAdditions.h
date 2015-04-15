#import <UIKit/UIKit.h>

typedef void(^JFFVisitIndexPath)(NSIndexPath *indexPath);

@interface UITableView (BlocksAdditions)

- (void)enumerateAllIndexPaths:(JFFVisitIndexPath)block;

@end
