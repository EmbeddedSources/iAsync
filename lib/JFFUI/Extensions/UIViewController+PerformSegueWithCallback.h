#import <UIKit/UIKit.h>

typedef void(^JFFPerformSegueCallback)(UIStoryboardSegue *);

@interface UIViewController (PerformSegueWithCallback)

- (void)performSegueWithIdentifier:(NSString *)identifier
                            sender:(id)sender
                          callback:(JFFPerformSegueCallback)callback;

@end
