#import "JFFAsyncOperationLoadBalancerContexts.h"

#import "JFFContextLoaders.h"

@implementation JFFAsyncOperationLoadBalancerContexts
{
    NSMutableDictionary *_contextLoadersByName;
}

+ (instancetype)sharedBalancer
{
    NSParameterAssert([NSThread isMainThread]);
    static JFFAsyncOperationLoadBalancerContexts *instance;
    
    if (!instance) {
        instance = [self new];
    }
    
    return instance;
}

- (NSString *)currentContextName
{
    if (!_currentContextName) {
        _currentContextName = self.activeContextName;
    }
    return _currentContextName;
}

- (NSString *)activeContextName
{
    if (!_activeContextName ) {
        _activeContextName = @"default";
    }
    return _activeContextName;
}

- (NSMutableDictionary *)contextLoadersByName
{
    if (!_contextLoadersByName) {
        _contextLoadersByName = [NSMutableDictionary new];
    }
    return _contextLoadersByName;
}

- (JFFContextLoaders *)contextLoadersForName:(NSString *)name
{
    JFFContextLoaders *contextLoaders = _contextLoadersByName[name];
    if (!contextLoaders) {
        contextLoaders = [JFFContextLoaders new];
        contextLoaders.name = name;
        
        self.contextLoadersByName[name] = contextLoaders;
    }
    return contextLoaders;
}

- (JFFContextLoaders *)activeContextLoaders
{
    return [self contextLoadersForName:self.activeContextName];
}

- (JFFContextLoaders *)currentContextLoaders
{
    return [self contextLoadersForName:self.currentContextName];
}

@end
