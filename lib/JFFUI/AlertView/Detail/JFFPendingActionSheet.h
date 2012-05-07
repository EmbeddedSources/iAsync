#import <Foundation/Foundation.h>

@class JFFActionSheet;

@interface JFFPendingActionSheet : NSObject

@property ( nonatomic ) JFFActionSheet* actionSheet;
@property ( nonatomic ) UIView* view;

-(id)initWithActionSheet:( JFFActionSheet* )actionSheet_
                    view:( UIView* )view_;

@end
