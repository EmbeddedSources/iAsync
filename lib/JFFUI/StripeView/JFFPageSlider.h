#import <JFFUtils/JSignedRange.h>

#import <UIKit/UIKit.h>

@protocol JFFPageSliderDelegate;

@interface JFFPageSlider : UIView

@property (nonatomic, readonly) UIScrollView *scrollView;

@property (nonatomic, readonly) NSInteger activeIndex;
@property (nonatomic, readonly) NSInteger firstIndex;
@property (nonatomic, readonly) NSInteger lastIndex;
@property (nonatomic, readonly) NSMutableDictionary *viewByIndex;

@property (nonatomic, weak) IBOutlet id< JFFPageSliderDelegate > delegate;

- (id)initWithFrame:(CGRect)frame
           delegate:(id< JFFPageSliderDelegate >)delegate;

- (void)reloadData;

- (UIView *)elementAtIndex:(NSInteger)index;

- (NSArray *)visibleElements;

- (void)slideForward;
- (void)slideBackward;

- (void)pushFrontElement;
- (void)pushBackElement;

- (void)slideToIndex:(NSInteger)index animated:(BOOL)animated;
- (void)slideToIndex:(NSInteger)index;

- (UIView *)viewAtIndex:(NSInteger)index;

- (void)removeViewsInRange:(JSignedRange)range;

@end
