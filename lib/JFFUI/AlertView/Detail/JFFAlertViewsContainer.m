#import "JFFAlertViewsContainer.h"

#import "JFFAlertView.h"

@implementation JFFAlertViewsContainer
{
    NSMutableArray* _activeAlertViews;
}

+(id)sharedAlertViewsContainer
{
    static id instance_ = nil;
    if ( !instance_ )
    {
        instance_ = [ self new ];
    }
    return instance_;
}

-(void)addAlertView:( JFFAlertView* )alertView_
{
    if ( !self->_activeAlertViews )
    {
        self->_activeAlertViews = [ [ NSMutableArray alloc ] initWithCapacity: 1 ];
    }

    [ self->_activeAlertViews addObject: alertView_ ];
}

-(void)removeAlertView:( JFFAlertView* )alertView_
{
    if ( !self->_activeAlertViews )
        return;

    [ self->_activeAlertViews removeObject: alertView_ ];

    if ( ![ self->_activeAlertViews count ] )
    {
        self->_activeAlertViews = nil;
    }
}

-(BOOL)containsAlertView:( JFFAlertView* )alertView_
{
    return [ self->_activeAlertViews containsObject: alertView_ ];
}

-(JFFAlertView*)firstAlertView
{
    return [ self->_activeAlertViews noThrowObjectAtIndex: 0 ];
}

-(NSUInteger)count
{
    return [ self->_activeAlertViews count ];
}

-(NSArray*)allAlertViews
{
    return _activeAlertViews
        ? [ [ NSArray new ] initWithArray: _activeAlertViews ]
        : [ NSArray new ];
}

-(void)removeAllAlertViews
{
    self->_activeAlertViews = nil;
}

@end
