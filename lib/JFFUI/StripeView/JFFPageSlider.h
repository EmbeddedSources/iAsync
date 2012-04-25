#import <JFFUtils/JSignedRange.h>

#import <UIKit/UIKit.h>

@protocol JFFPageSliderDelegate;

@interface JFFPageSlider : UIView

@property ( nonatomic, strong, readonly ) UIScrollView* scrollView;

@property ( nonatomic, assign, readonly ) NSInteger activeIndex;
@property ( nonatomic, assign, readonly ) NSInteger firstIndex;
@property ( nonatomic, assign, readonly ) NSInteger lastIndex;
@property ( nonatomic, strong, readonly ) NSMutableDictionary* viewByIndex;

@property ( nonatomic, unsafe_unretained ) IBOutlet id< JFFPageSliderDelegate > delegate;

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
