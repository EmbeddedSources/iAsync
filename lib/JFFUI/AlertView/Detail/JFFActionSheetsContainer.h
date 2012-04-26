#import <Foundation/Foundation.h>

@class JFFActionSheet;
@class JFFPendingActionSheet;

@interface JFFActionSheetsContainer : NSObject

+(id)sharedActionSheetsContainer;

-(NSUInteger)count;

-(void)addActionSheet:( JFFActionSheet* )actionSheet_ withView:( UIView* )view_;
-(void)removeActionSheet:( JFFActionSheet* )actionSheet_;
-(BOOL)containsActionSheet:( JFFActionSheet* )actionSheet_;

-(JFFPendingActionSheet*)firstPendingActionSheet;

-(NSArray*)allActionSheets;
-(void)removeAllActionSheets;

@end
