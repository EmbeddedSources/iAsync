#import "UITableView+WithinUpdates.h"

@implementation UITableView (WithinUpdates)

-(void)withinUpdates:( void (^)( void ) )block_
{
    [ self beginUpdates ];

    @try
    {
        block_();
    }
    @finally
    {
        [ self endUpdates ];
    }
}

@end
