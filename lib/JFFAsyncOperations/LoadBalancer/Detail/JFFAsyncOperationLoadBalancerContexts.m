#import "JFFAsyncOperationLoadBalancerContexts.h"

#import "JFFContextLoaders.h"

@implementation JFFAsyncOperationLoadBalancerContexts

@synthesize currentContextName = _current_context_name;
@synthesize activeContextName = _active_context_name;
@synthesize contextLoadersByName = _context_loaders_by_name;

-(void)dealloc
{
   [ _current_context_name release ];
   [ _active_context_name release ];
   [ _context_loaders_by_name release ];

   [ super dealloc ];
}

+(id)sharedBalancer
{
   [ NSThread assertMainThread ];
   static JFFAsyncOperationLoadBalancerContexts* instance_ = nil;

   if ( !instance_ )
   {
      instance_ = [ self new ];
   }

   return instance_;
}

-(NSArray*)allContextNames
{
   return [ self.contextLoadersByName allKeys ];
}

-(NSString*)currentContextName
{
   if ( !_current_context_name )
   {
      _current_context_name = [ self.activeContextName retain ];
   }
   return _current_context_name;
}

-(NSString*)activeContextName
{
   if ( !_active_context_name )
   {
      _active_context_name = [ @"default" retain ];
   }
   return _active_context_name;
}

-(NSMutableDictionary*)contextLoadersByName
{
   if ( !_context_loaders_by_name )
   {
      _context_loaders_by_name = [ NSMutableDictionary new ];
   }
   return _context_loaders_by_name;
}

-(JFFContextLoaders*)contextLoadersForName:( NSString* )name_
{
   JFFContextLoaders* context_loaders_ = [ self.contextLoadersByName objectForKey: name_ ];
   if ( !context_loaders_ )
   {
      context_loaders_ = [ JFFContextLoaders new ];
      context_loaders_.name = name_;

      [ self.contextLoadersByName setValue: context_loaders_ forKey: name_ ];

      [ context_loaders_ release ];
   }
   return context_loaders_;
}

-(JFFContextLoaders*)activeContextLoaders
{
   return [ self contextLoadersForName: self.activeContextName ];
}

-(JFFContextLoaders*)currentContextLoaders
{
   return [ self contextLoadersForName: self.currentContextName ];
}

@end
