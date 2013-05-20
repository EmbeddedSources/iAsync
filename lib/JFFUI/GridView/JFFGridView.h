#import <UIKit/UIKit.h>

typedef enum
{
   JFFGridOrientationUndefined
   , JFFGridOrientationVertical
   , JFFGridOrientationGorizontal
} JFFGridOrientation;

@class JFFRemoveButton;

@interface JFFGridViewContext : NSObject

@property (nonatomic) JFFRemoveButton *removeButton;
@property (nonatomic) UIView *view;

@end

@protocol JFFGridViewDelegate;

@interface JFFGridView : UIView

@property (weak, nonatomic) IBOutlet id<JFFGridViewDelegate> delegate;

@property (nonatomic, readonly) UIScrollView *scrollView;

- (void)reloadData;
- (void)reloadDataWithRange:(NSRange)range;

- (void)scrollToIndex:(NSInteger)index;

- (id)dequeueReusableElementWithIdentifier:(NSString *)identifier;

- (void)removeElementWithIndex:(NSUInteger)index animated:(BOOL)animated;
- (NSMutableSet *)visibleIndexes;
- (id)elementByIndex:(NSUInteger)index;
- (CGRect)rectForElementWithIndex:(NSUInteger)index;

@end
