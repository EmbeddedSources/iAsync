#import <Foundation/Foundation.h>

@class JFFPageSlider;

@protocol JFFPageSliderDelegate <NSObject>

@required
- (NSInteger)numberOfElementsInStripeView:(JFFPageSlider *)pageSlider;

- (UIView *)stripeView:(JFFPageSlider *)pageSlider
        elementAtIndex:(NSInteger)index;

- (void)pageSlider:(JFFPageSlider *)pageSlider
didChangeActiveElementFrom:(NSInteger)previousIndex
                        to:(NSInteger)activeIndex;

@optional
- (void)pageSlider:(JFFPageSlider *)pageSlider
handleMemoryWarningForElementAtIndex:(NSInteger)elementIndex;

@end
