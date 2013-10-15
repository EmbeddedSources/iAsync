#import "UITableView+BlocksAdditions.h"

@implementation UITableView (BlocksAdditions)

- (void)enumerateAllIndexPaths:(JFFVisitIndexPath)block
{
    NSParameterAssert(block);
    
    NSUInteger numberOfSections = [self numberOfSections];
    
    for (NSUInteger section = 0; section < numberOfSections; ++section) {
        
        @autoreleasepool {
            NSUInteger numberOfRows = [self numberOfRowsInSection:section];
            for (NSUInteger row = 0; row < numberOfRows; ++row) {
                
                @autoreleasepool {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
                    block(indexPath);
                }
            }
        }
    }
}

@end
