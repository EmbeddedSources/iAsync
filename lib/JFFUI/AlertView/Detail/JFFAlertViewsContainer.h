#import <Foundation/Foundation.h>

@class JFFAlertView;

@interface JFFAlertViewsContainer : NSObject

+(id)sharedAlertViewsContainer;

-(NSUInteger)count;

-(void)addAlertView:( JFFAlertView* )alertView_;
-(void)removeAlertView:( JFFAlertView* )alertView_;
-(BOOL)containsAlertView:( JFFAlertView* )alertView_;

-(JFFAlertView*)firstAlertView;

-(NSArray*)allAlertViews;
-(void)removeAllAlertViews;

@end
