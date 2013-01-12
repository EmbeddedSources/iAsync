#import <UIKit/UIKit.h>

@interface UIViewController (PresentTopViewController)

- (void)presentTopViewController:(UIViewController *)viewControllerToPresent;

- (void)presentTopViewController:(UIViewController *)viewControllerToPresent
                        animated:(BOOL)flag
                      completion:(void (^)(void))completion;

@end
