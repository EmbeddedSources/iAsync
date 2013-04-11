#import "JFFCacheAdapter.h"

#import "JFFResponseDataWithUpdateData.h"

#import <JFFCache/JFFCacheDB.h>

@implementation JFFCacheAdapter
{
    JFFCacheFactory _cacheFactory;
    NSString *_cacheQueueName;
}

+ (id)newCacheAdapterWithCacheFactory:(JFFCacheFactory)cacheFactory
                       cacheQueueName:(NSString *)cacheQueueName
{
    NSParameterAssert(cacheFactory);
    
    JFFCacheAdapter *result = [JFFCacheAdapter new];
    
    if (result) {
        
        result->_cacheQueueName = cacheQueueName;
        result->_cacheFactory = [cacheFactory copy];
    }
    
    return result;
}

- (JFFAsyncOperation)loaderToSetData:(NSData *)data forKey:(NSString *)key
{
    return asyncOperationWithSyncOperationAndQueue(^id(NSError *__autoreleasing *outError) {
        
        [_cacheFactory() setData:data forKey:key];
        return [NSNull new];
    }, [_cacheQueueName cStringUsingEncoding:NSUTF8StringEncoding]);
}

- (JFFAsyncOperation)cachedDataLoaderForKey:(NSString *)key {
    
    return asyncOperationWithSyncOperationAndQueue(^id(NSError *__autoreleasing *outError) {
        
        NSDate *date;
        NSData *data = [_cacheFactory() dataForKey:key lastUpdateTime:&date];
        
        if (data) {
            JFFResponseDataWithUpdateData *result = [JFFResponseDataWithUpdateData new];
            result.data       = data;
            result.updateDate = date;
            return result;
        }
        
        if (outError) {
            NSString *description = [[NSString alloc] initWithFormat:@"no cached data for key: %@", key];
            *outError = [JFFError newErrorWithDescription:description];
        }
        
        return nil;
    }, [_cacheQueueName cStringUsingEncoding:NSUTF8StringEncoding]);
}

@end
