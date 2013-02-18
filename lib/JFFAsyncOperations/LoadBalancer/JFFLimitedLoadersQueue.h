#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@interface JFFLimitedLoadersQueue : NSObject

//default value is 10
@property (nonatomic) NSUInteger limitCount;

//TODO20 immediately cancel callback
- (JFFAsyncOperation)balancedLoaderWithLoader:(JFFAsyncOperation)loader;

- (JFFAsyncOperation)barrierBalancedLoaderWithLoader:(JFFAsyncOperation)loader;

@end
