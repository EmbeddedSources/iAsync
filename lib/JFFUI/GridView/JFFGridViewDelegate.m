#import "JFFGridViewDelegate.h"

@implementation NSObject (JFFGridViewDelegate)

- (BOOL)gridView:(JFFGridView *)gridView
canRemoveElementAtIndex:( NSUInteger )index_
{
    return NO;
}

- (void)gridView:(JFFGridView *)gridView
removeElementAtIndex:( NSUInteger )index_
{
}

- (void)gridView:(JFFGridView *)gridView
  didMoveElement:( UIView* )view_
         toIndex:( NSUInteger )index_
{
}

- (BOOL)verticalGridView:(JFFGridView *)gridView
{
    return YES;
}

@end
