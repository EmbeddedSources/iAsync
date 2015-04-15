#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@protocol JFFRestKitCachedData <NSObject, NSCopying>

@required
- (NSData *)data;
- (NSDate *)updateDate;

@end

@protocol JFFRestKitCache <NSObject>

@required
- (JFFAsyncOperation)loaderToSetData:(NSData *)data forKey:(NSString *)key;

//returns JFFRestKitCachedData instance in result callback
- (JFFAsyncOperation)cachedDataLoaderForKey:(NSString *)key;

@end
