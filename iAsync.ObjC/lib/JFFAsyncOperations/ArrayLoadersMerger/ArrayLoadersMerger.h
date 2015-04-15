#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

typedef JFFAsyncOperation(^JFFArrayOfObjectsLoader)(NSArray *keys);

@interface ArrayLoadersMerger : NSObject

+ (instancetype)newArrayLoadersMergerWithArrayOfObjectsLoader:(JFFArrayOfObjectsLoader)arrayOfObjectsLoader;

- (JFFAsyncOperation)oneObjectLoaderForKey:(id<NSCopying, NSObject>)key;

@end
