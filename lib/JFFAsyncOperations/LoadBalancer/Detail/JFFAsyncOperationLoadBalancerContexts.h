#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@class JFFContextLoaders;

@interface JFFAsyncOperationLoadBalancerContexts : NSObject

@property (nonatomic) NSString *currentContextName;
@property (nonatomic) NSString *activeContextName;
@property (nonatomic, readonly) NSMutableDictionary *contextLoadersByName;

+ (instancetype)sharedBalancer;

- (JFFContextLoaders *)activeContextLoaders;
- (JFFContextLoaders *)currentContextLoaders;

- (JFFContextLoaders *)contextLoadersForName:(NSString *)name;

@end
