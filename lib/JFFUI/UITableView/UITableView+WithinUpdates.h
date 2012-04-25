#import <UIKit/UIKit.h>

@interface UITableView (WithinUpdates)

-(void)withinUpdates:( void (^)( void ) )block_;

@end
