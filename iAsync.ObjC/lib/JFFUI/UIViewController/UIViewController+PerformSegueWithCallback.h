#import <UIKit/UIKit.h>

typedef void(^JFFPerformSegueCallback)(UIStoryboardSegue *segue);

@interface UIViewController (PerformSegueWithCallback)

- (void)performSegueWithIdentifier:(NSString *)identifier
                            sender:(id)sender
                          callback:(JFFPerformSegueCallback)callback;

@end
