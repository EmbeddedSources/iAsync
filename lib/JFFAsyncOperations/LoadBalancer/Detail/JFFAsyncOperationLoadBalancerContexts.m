#import "JFFAsyncOperationLoadBalancerContexts.h"

#import "JFFContextLoaders.h"

@implementation JFFAsyncOperationLoadBalancerContexts

@synthesize currentContextName = _currentContextName;
@synthesize activeContextName = _activeContextName;
@synthesize contextLoadersByName = _contextLoadersByName;

-(void)dealloc
{
    [ _currentContextName release ];
    [ _activeContextName release ];
    [ _contextLoadersByName release ];

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

-(NSString*)currentContextName
{
    if ( !_currentContextName )
    {
        _currentContextName = [ self.activeContextName retain ];
    }
    return _currentContextName;
}

-(NSString*)activeContextName
{
    if ( !_activeContextName )
    {
        _activeContextName = [ @"default" retain ];
    }
    return _activeContextName;
}

-(NSMutableDictionary*)contextLoadersByName
{
    if ( !_contextLoadersByName )
    {
        _contextLoadersByName = [ NSMutableDictionary new ];
    }
    return _contextLoadersByName;
}

-(JFFContextLoaders*)contextLoadersForName:( NSString* )name_
{
    JFFContextLoaders* contextLoaders_ = [ self.contextLoadersByName objectForKey: name_ ];
    if ( !contextLoaders_ )
    {
        contextLoaders_ = [ JFFContextLoaders new ];
        contextLoaders_.name = name_;

        [ self.contextLoadersByName setValue: contextLoaders_ forKey: name_ ];

        [ contextLoaders_ release ];
    }
    return contextLoaders_;
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
