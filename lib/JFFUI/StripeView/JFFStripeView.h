#import <UIKit/UIKit.h>

@protocol JFFStripeViewDelegate;

@interface JFFStripeView : UIView

@property (nonatomic, readonly) UIScrollView *scrollView;
@property (nonatomic, readonly) UILabel *warningLabel;
@property (nonatomic, readonly) UIView *activeElementView;
@property (nonatomic, readonly) NSUInteger activeElement;

@property (weak, nonatomic) IBOutlet id<JFFStripeViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame
           delegate:(id<JFFStripeViewDelegate>)delegate;

- (void)reloadData;

- (void)relayoutElements;

- (id)dequeueReusableElement;

- (UIView *)elementAtIndex:(NSUInteger)index;

- (NSOrderedSet *)visibleIndexes;

- (void)removeElementWithIndex:(NSUInteger)index
                      animated:(BOOL)animated;

- (void)insertElementAtIndex:(NSUInteger)index
                    animated:(BOOL)animated;

- (void)exchangeElementAtIndex:(NSUInteger)firstIndex
            withElementAtIndex:(NSUInteger)secondIndex;

- (void)slideForward;

- (void)slideToIndex:(NSInteger)index animated:(BOOL)animated;

- (void)slideToIndex:(NSInteger)index;

@end
