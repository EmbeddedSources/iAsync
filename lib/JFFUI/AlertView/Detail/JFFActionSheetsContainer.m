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
    if ( !_activeActionSheets )
    {
        _activeActionSheets = [ [ NSMutableArray alloc ] initWithCapacity: 1 ];
    }

    JFFPendingActionSheet* pendingActionSheet_ = [ [ JFFPendingActionSheet alloc ] initWithActionSheet: actionSheet_
                                                                                                  view: view_ ];

    [ _activeActionSheets addObject: pendingActionSheet_ ];
}

-(void)removeActionSheet:( JFFActionSheet* )actionSheet_
{
    if ( !_activeActionSheets )
        return;

    [ _activeActionSheets removeObject: [ self objectToRemove: actionSheet_ ] ];

    if ( ![ _activeActionSheets count ] )
    {
        _activeActionSheets = nil;
    }
}

- (BOOL)containsActionSheet:(JFFActionSheet *)actionSheet
{
    return [_activeActionSheets any:^BOOL(JFFPendingActionSheet *pendingActionSheet)
    {
        return pendingActionSheet.actionSheet == actionSheet;
    }];
}

-(JFFPendingActionSheet*)firstPendingActionSheet
{
    return [ _activeActionSheets noThrowObjectAtIndex: 0 ];
}

-(NSUInteger)count
{
    return [ _activeActionSheets count ];
}

-(JFFPendingActionSheet*)objectToRemove:( JFFActionSheet* )actionSheet_
{
    return [_activeActionSheets firstMatch:^BOOL(JFFPendingActionSheet *pendingActionSheet_)
    {
        return pendingActionSheet_.actionSheet ==  actionSheet_;
    }];
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
    _activeActionSheets = nil;
}

@end
