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

-(void)scrollToIndex:( NSInteger )index_;

- (id)dequeueReusableElementWithIdentifier:(NSString *)identifier;

-(void)removeElementWithIndex:( NSUInteger )index_ animated:( BOOL )animated_;
-(NSMutableSet*)visibleIndexes;
-(UIView*)elementByIndex:( NSUInteger )index_;
-(CGRect)rectForElementWithIndex:( NSUInteger )index_;

@end
