#import "JFFMulticastDelegate.h"

#import "JFFMutableAssignArray.h"

@interface JFFMulticastDelegate ()

@property ( nonatomic, strong ) JFFMutableAssignArray* delegates;

@end

@implementation JFFMulticastDelegate

@synthesize delegates = _delegates;

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

   for( id delegate_ in _delegates.array )
   {
      if ( [ delegate_ respondsToSelector: selector_ ] )
      {
         [ invocation_ invokeWithTarget: delegate_ ];
      }
   }
}

-(NSMethodSignature*)methodSignatureForSelector:( SEL )selector_
{
   for( id delegate_ in _delegates.array )
   {
      NSMethodSignature* result_ = [ delegate_ methodSignatureForSelector: selector_ ];
      if( result_ )
         return result_;
   }

   return [ [ self class ] instanceMethodSignatureForSelector: @selector( doNothing ) ];
}

-(void)doNothing
{
}

@end
