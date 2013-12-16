#import "JFFGridViewDelegate.h"

@implementation NSObject (JFFGridViewDelegate)

- (void)gridView:(JFFGridView *)gridView
removeElementAtIndex:(NSUInteger)index
{
}

- (void)gridView:(JFFGridView *)gridView
  didMoveElement:(UIView *)view
         toIndex:(NSUInteger)index
{
}

- (BOOL)verticalGridView:(JFFGridView *)gridView
{
    return YES;
}

@end
