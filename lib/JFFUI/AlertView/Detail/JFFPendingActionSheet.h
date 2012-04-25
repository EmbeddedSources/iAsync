#import <Foundation/Foundation.h>

@class JFFActionSheet;

@interface JFFPendingActionSheet : NSObject

@property ( nonatomic, strong ) JFFActionSheet* actionSheet;
@property ( nonatomic, strong ) UIView* view;

-(id)initWithActionSheet:( JFFActionSheet* )actionSheet_
                    view:( UIView* )view_;

@end
