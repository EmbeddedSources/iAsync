#import <UIKit/UIKit.h>

typedef void(^JFFVisitIndexPath)(NSIndexPath *indexPath);

//TODO move to UITableView folder
@interface UITableView (BlocksAdditions)

- (void)enumerateAllIndexPaths:(JFFVisitIndexPath)block;

@end
