#import "JFFAsyncOperationLoadBalancerContexts.h"

#import "JFFContextLoaders.h"

@implementation JFFAsyncOperationLoadBalancerContexts
{
    NSMutableDictionary* _contextLoadersByName;
}

-(void)dealloc
{
    [self->_currentContextName   release];
    [self->_activeContextName    release];
    [self->_contextLoadersByName release];
    
    [super dealloc];
}

+ (id)sharedBalancer
{
    [NSThread assertMainThread];
    static JFFAsyncOperationLoadBalancerContexts *instance;
    
    if (!instance) {
        instance = [ self new ];
    }
    
    return instance;
}

-(NSString*)currentContextName
{
    if ( !self->_currentContextName )
    {
        self->_currentContextName = [ self.activeContextName retain ];
    }
    return self->_currentContextName;
}

-(NSString*)activeContextName
{
    if ( !self->_activeContextName )
    {
        self->_activeContextName = [ @"default" retain ];
    }
    return self->_activeContextName;
}

-(NSMutableDictionary*)contextLoadersByName
{
    if ( !self->_contextLoadersByName )
    {
        self->_contextLoadersByName = [ NSMutableDictionary new ];
    }
    return self->_contextLoadersByName;
}

-(JFFContextLoaders*)contextLoadersForName:( NSString* )name_
{
    JFFContextLoaders* contextLoaders_ = self.contextLoadersByName[ name_ ];
    if ( !contextLoaders_ )
    {
        contextLoaders_ = [ JFFContextLoaders new ];
        contextLoaders_.name = name_;

        self.contextLoadersByName[ name_ ] = contextLoaders_;

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
