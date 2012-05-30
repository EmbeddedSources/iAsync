#import "JFFActionSheetsContainer.h"

#import "JFFActionSheet.h"
#import "JFFPendingActionSheet.h"

@implementation JFFActionSheetsContainer
{
    NSMutableArray* _activeActionSheets;
}

+(id)sharedActionSheetsContainer
{
    static id instance_ = nil;
    if ( !instance_ )
    {
        instance_ = [ self new ];
    }
    return instance_;
}

-(void)addActionSheet:( JFFActionSheet* )actionSheet_ withView:( UIView* )view_
{
    if ( !self->_activeActionSheets )
    {
        self->_activeActionSheets = [ [ NSMutableArray alloc ] initWithCapacity: 1 ];
    }

    JFFPendingActionSheet* pendingActionSheet_ = [ [ JFFPendingActionSheet alloc ] initWithActionSheet: actionSheet_
                                                                                                  view: view_ ];

    [ self->_activeActionSheets addObject: pendingActionSheet_ ];
}

-(void)removeActionSheet:( JFFActionSheet* )actionSheet_
{
    if ( !self->_activeActionSheets )
        return;

    [ self->_activeActionSheets removeObject: [ self objectToRemove: actionSheet_ ] ];

    if ( ![ self->_activeActionSheets count ] )
    {
        self->_activeActionSheets = nil;
    }
}

-(BOOL)containsActionSheet:( JFFActionSheet* )actionSheet_
{
    return [ self->_activeActionSheets firstMatch: ^BOOL( JFFPendingActionSheet* pendingActionSheet_ )
    {
        return pendingActionSheet_.actionSheet == actionSheet_;
    } ] != nil;
}

-(JFFPendingActionSheet*)firstPendingActionSheet
{
    return [ self->_activeActionSheets noThrowObjectAtIndex: 0 ];
}

-(NSUInteger)count
{
    return [ self->_activeActionSheets count ];
}

-(JFFPendingActionSheet*)objectToRemove:( JFFActionSheet* )actionSheet_
{
    return [ self->_activeActionSheets firstMatch: ^BOOL( JFFPendingActionSheet* pendingActionSheet_ )
    {
        return pendingActionSheet_.actionSheet ==  actionSheet_;
    } ];
}

-(NSArray*)allActionSheets
{
    return [ _activeActionSheets map: ^id( JFFPendingActionSheet* object_ )
    {
        return object_.actionSheet;
    } ];
}

-(void)removeAllActionSheets
{
    self->_activeActionSheets = nil;
}

@end
