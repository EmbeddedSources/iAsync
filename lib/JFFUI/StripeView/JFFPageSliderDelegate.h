#import <Foundation/Foundation.h>

@class JFFPageSlider;

@protocol JFFPageSliderDelegate < NSObject >

@required
-(NSInteger)numberOfElementsInStripeView:( JFFPageSlider* )pageSlider_;

-(UIView*)stripeView:( JFFPageSlider* )pageSlider_
      elementAtIndex:( NSInteger )index_;

-(void)pageSlider:( JFFPageSlider* )pageSlider_
didChangeActiveElementFrom:( NSInteger )previousIndex_
                        to:( NSInteger )activeIndex_;

@optional
-(void)pageSlider:( JFFPageSlider* )pageSlider_
handleMemoryWarningForElementAtIndex:( NSInteger )element_index_;

@end
