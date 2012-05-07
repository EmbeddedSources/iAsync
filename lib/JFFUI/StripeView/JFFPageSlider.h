#import <JFFUtils/JSignedRange.h>

#import <UIKit/UIKit.h>

@protocol JFFPageSliderDelegate;

@interface JFFPageSlider : UIView

@property ( nonatomic, readonly ) UIScrollView* scrollView;

@property ( nonatomic, readonly ) NSInteger activeIndex;
@property ( nonatomic, readonly ) NSInteger firstIndex;
@property ( nonatomic, readonly ) NSInteger lastIndex;
@property ( nonatomic, readonly ) NSMutableDictionary* viewByIndex;

@property ( nonatomic, weak ) IBOutlet id< JFFPageSliderDelegate > delegate;

-(id)initWithFrame:( CGRect )frame_
          delegate:( id< JFFPageSliderDelegate > )delegate_;

-(void)reloadData;

-(UIView*)elementAtIndex:( NSInteger )index_;

-(NSArray*)visibleElements;

-(void)slideForward;
-(void)slideBackward;

-(void)pushFrontElement;
-(void)pushBackElement;

-(void)slideToIndex:( NSInteger )index_ animated:(BOOL)animated_;
-(void)slideToIndex:( NSInteger )index_;

-(UIView*)viewAtIndex:( NSInteger )index_;

-(void)removeViewsInRange:( JSignedRange )range_;

@end
