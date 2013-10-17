#import <UIKit/UIView.h>

@interface UIView (AllSubviews)

- (instancetype)findSubviewOfClass:(Class)cls;

- (void)logAllSubviews;

- (void)removeAllSubviews;

@end
