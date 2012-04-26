#import <UIKit/UIView.h>

@interface UIView (AllSubviews)

-(UIView*)findSubviewOfClass:( Class )class_;

-(void)logAllSubviews;

-(void)removeAllSubviews;

@end
