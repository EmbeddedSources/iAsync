#import <Foundation/Foundation.h>

@class JFFPageSlider;

@protocol JFFPageSliderDelegate < NSObject >

@required
- (NSInteger)numberOfElementsInStripeView:( JFFPageSlider* )pageSlider_;

- (UIView *)stripeView:(JFFPageSlider *)pageSlider_
        elementAtIndex:(NSInteger)index_;

- (void)pageSlider:(JFFPageSlider *)pageSlider
didChangeActiveElementFrom:(NSInteger)previousIndex
                        to:(NSInteger)activeIndex;

@optional
- (void)pageSlider:(JFFPageSlider *)pageSlider
handleMemoryWarningForElementAtIndex:(NSInteger)element_index_;

@end
