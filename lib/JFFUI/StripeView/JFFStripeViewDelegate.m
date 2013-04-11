#import "JFFStripeViewDelegate.h"

@implementation NSObject ( ESStripeViewControllerDelegate )

- (CGFloat)elementOffsetInStripeView:(JFFStripeView *)stripeView
{
   return 0.f;
}

- (CGFloat)elementVericalOffsetInStripeView:(JFFStripeView *)stripeView
{
   return [self elementOffsetInStripeView:stripeView];
}

- (NSUInteger)activeElementForStripeView:(JFFStripeView *)stripeView
{
   return 0;
}

- (UIView *)backgroundViewForStripeView:(JFFStripeView *)stripeView
{
   return nil;
}

- (UIView *)overlayViewForStripeView:(JFFStripeView *)stripeView
{
   return nil;
}

- (CGFloat)leftFractionInsetInStripeView:(JFFStripeView *)stripeView
{
   return 0.f;
}

- (CGFloat)rightFractionInsetInStripeView:(JFFStripeView *)stripeView
{
   return 0.f;
}

- (void)stripeView:(JFFStripeView *)stripeView
willChangeActiveElementFrom:( NSUInteger )active_element_
{
}

- (void)stripeView:(JFFStripeView *)stripeView
didChangeActiveElementFrom:( NSUInteger )old_active_element_
                        to:( NSUInteger )new_active_element_
{
}

- (void)willRelayoutStripeView:(JFFStripeView *)stripeView
{
}

- (void)didRelayoutStripeView:(JFFStripeView *)stripeView
{
}

- (void)didStopScrollingStripeView:(JFFStripeView *)stripeView
{
}

- (BOOL)isCyclicStripeView:(JFFStripeView *)stripeView
{
   return NO;
}

- (void)stripeView:(JFFStripeView *)stripeView
didChangeActivePage:(NSUInteger)activePage
     numberOfPages:(NSUInteger)numberOfPages
{
}

- (void)stripeViewWasDragged:(JFFStripeView *)stripeView
{
}

- (BOOL)animationEnabledOnStripeViewRelayout:(JFFStripeView *)stripeView
{
   return NO;
}

- (CGFloat)animationDurationOnStripeViewRelayout:(JFFStripeView *)stripeView
{
   // feature disabled
   return -1.f;
}

@end
