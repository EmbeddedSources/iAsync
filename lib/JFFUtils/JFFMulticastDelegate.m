#import "JFFMulticastDelegate.h"

#import "JFFMutableAssignArray.h"

@implementation JFFMulticastDelegate
{
    JFFMutableAssignArray* _delegates;
}

-(JFFMutableAssignArray*)delegates
{
    if ( !_delegates )
    {
        _delegates = [ JFFMutableAssignArray new ];
    }
    return _delegates;
}

-(void)addDelegate:( id )delegate_
{
    if ( ![ self.delegates containsObject: delegate_ ] )
    {
        [ self.delegates addObject: delegate_ ];
    }
}

-(void)removeDelegate:( id )delegate_
{
    [ _delegates removeObject: delegate_ ];
}

-(void)removeAllDelegates
{
    [ _delegates removeAllObjects ];
}

-(void)forwardInvocation:( NSInvocation* )invocation_
{
    SEL selector_ = [ invocation_ selector ];

    [ _delegates enumerateObjectsUsingBlock: ^void( id delegate_
                                                   , NSUInteger idx_
                                                   , BOOL* stop_ )
    {
        if ( [ delegate_ respondsToSelector: selector_ ] )
        {
            [ invocation_ invokeWithTarget: delegate_ ];
        }
    } ];
}

-(NSMethodSignature*)methodSignatureForSelector:( SEL )selector_
{
    __block NSMethodSignature* result_ = nil;
    [ _delegates enumerateObjectsUsingBlock: ^void( id delegate_
                                                   , NSUInteger idx_
                                                   , BOOL* stop_ )
    {
        result_ = [ delegate_ methodSignatureForSelector: selector_ ];
        if( result_ )
            *stop_ = YES;
    } ];

    if ( result_ )
        return result_;

    return [ [ self class ] instanceMethodSignatureForSelector: @selector( doNothing ) ];
}

-(void)doNothing
{
}

@end
