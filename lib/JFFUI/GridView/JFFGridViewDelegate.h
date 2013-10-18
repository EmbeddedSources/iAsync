#import <UIKit/UIKit.h>

@class JFFGridView;

@protocol JFFGridViewDelegate <NSObject>

@required
- (NSUInteger)numberOfElementsInGridView:(JFFGridView *)gridView;

- (NSUInteger)numberOfElementsInRowInGridView:(JFFGridView *)gridView;

- (UIView *)gridView:(JFFGridView *)gridView
      elementAtIndex:( NSUInteger )index_;

- (CGFloat)widthHeightRelationInGridView:(JFFGridView *)gridView;

- (CGFloat)horizontalOffsetInGridView:(JFFGridView *)gridView;

- (CGFloat)verticalOffsetInGridView:(JFFGridView *)gridView;

@optional
- (void)gridView:(JFFGridView *)gridView
removeElementAtIndex:(NSUInteger)index;

- (void)gridView:(JFFGridView *)gridView
  didMoveElement:(UIView *)view_
         toIndex:(NSUInteger)index;

- (BOOL)verticalGridView:(JFFGridView *)gridView;

@end
