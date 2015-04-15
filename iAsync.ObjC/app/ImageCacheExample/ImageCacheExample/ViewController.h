#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIView *imagesContainer;

- (IBAction)reloadAllImages;
- (IBAction)clearAllCache;

@end
