#import <Foundation/Foundation.h>

@interface NSError (Alert)

- (void)showAlertWithTitle:(NSString *)title;

- (void)showErrorAlert;
- (void)showExclusiveErrorAlert;

@end
