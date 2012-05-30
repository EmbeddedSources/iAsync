#import <JFFUtils/NSArray/JUArrayHelperBlocks.h>

#import <Foundation/Foundation.h>

@class JFFAlertView;

@interface JFFAlertViewsContainer : NSObject

+(id)sharedAlertViewsContainer;

-(NSUInteger)count;

-(void)addAlertView:( JFFAlertView* )alertView_;
-(void)removeAlertView:( JFFAlertView* )alertView_;
-(BOOL)containsAlertView:( JFFAlertView* )alertView_;

-(JFFAlertView*)firstAlertView;

-(void)removeAllAlertViews;

-(void)each:( void(^)( JFFAlertView* alertView_ ) )block_;
-(id)firstMatch:( JFFPredicateBlock )predicate_;

@end
