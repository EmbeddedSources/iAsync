#import <UIKit/UIKit.h>

@class JFFStripeView;

@protocol JFFStripeViewDelegate< NSObject >

- (NSUInteger)numberOfElementsInStripeView:(JFFStripeView *)stripeView;

- (UIView *)stripeView:(JFFStripeView *)stripeView
        elementAtIndex:(NSUInteger)index;

- (NSUInteger)elementsPerPageInStripeView:(JFFStripeView *)stripeView;

//TODO change to active page?
- (NSUInteger)activeElementForStripeView:(JFFStripeView *)stripeView;

@optional

- (void)stripeViewDidScroll:(JFFStripeView *)stripeView;

- (CGFloat)elementOffsetInStripeView:(JFFStripeView *)stripeView;

- (CGFloat)elementVericalOffsetInStripeView:(JFFStripeView *)stripeView;

-(UIView*)backgroundViewForStripeView:(JFFStripeView *)stripeView;

-(UIView*)overlayViewForStripeView:(JFFStripeView *)stripeView;

- (CGFloat)leftFractionInsetInStripeView:(JFFStripeView *)stripeView;
- (CGFloat)rightFractionInsetInStripeView:(JFFStripeView *)stripeView;

- (void)stripeView:(JFFStripeView *)stripeView
willChangeActiveElementFrom:(NSUInteger)activeElement;

- (void)stripeView:(JFFStripeView *)stripeView
didChangeActiveElementFrom:(NSUInteger)oldActiveElement
                to:(NSUInteger)newActiveElement;

- (void)willRelayoutStripeView:(JFFStripeView *)stripeView;
- (void)didRelayoutStripeView:(JFFStripeView *)stripeView;

- (void)didStartScrollingStripeView:(JFFStripeView *)stripeView;
- (void)didStopScrollingStripeView:(JFFStripeView *)stripeView;

- (BOOL)isCyclicStripeView:(JFFStripeView *)stripeView;

- (void)stripeView:(JFFStripeView *)stripeView
didChangeActivePage:(NSUInteger)activePage
    numberOfPages:(NSUInteger)numberOfPages;

- (void)stripeViewWasDragged:(JFFStripeView *)stripeView;

#pragma mark -
#pragma mark animations
- (BOOL)animationEnabledOnStripeViewRelayout:(JFFStripeView *)stripeView;
- (CGFloat)animationDurationOnStripeViewRelayout:(JFFStripeView *)stripeView;

@end
