#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

typedef JFFAsyncOperation(^JFFArrayOfObjectsLoader)(NSArray *keys);

@interface ArrayLoadersMerger : NSObject

//- (instancetype)init NS_DESIGNATED_INITIALIZER;

+ (instancetype)newArrayLoadersMergerWithArrayOfObjectsLoader:(JFFArrayOfObjectsLoader)arrayOfObjectsLoader;

- (JFFAsyncOperation)oneObjectLoaderForKey:(id<NSCopying, NSObject>)key;

@end
