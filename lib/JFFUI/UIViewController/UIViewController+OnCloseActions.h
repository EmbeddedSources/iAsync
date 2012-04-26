#import <UIKit/UIKit.h>

typedef BOOL (^JFFWillCloseActionBlock) ( void );
typedef void (^JFFDidCloseActionBlock) ( BOOL ok_ );

@interface UIViewController (OnCloseActions)

//return TRUE if needs close controller animated
@property ( nonatomic, copy ) JFFWillCloseActionBlock willCloseAction;
@property ( nonatomic, copy ) JFFDidCloseActionBlock didCloseAction;

-(void)closeControllerWithReason:( BOOL )ok_;

@end
