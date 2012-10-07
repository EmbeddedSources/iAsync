#import "JFFThumbnailStorage.h"

#import "JFFCacheDB.h"
#import "JFFCaches.h"

#import <JFFRestKit/JFFRestKit.h>

#import <UIKit/UIKit.h>

//TODO try to use NSURLCache

static JFFAsyncBinderForURL imageDataToUIImageBinder()
{
    return ^JFFAsyncOperationBinder(NSURL *url) {
        return ^JFFAsyncOperation(NSData *imageData) {
            UIImage *image = [UIImage imageWithData:imageData];
            
            if (image)
                return asyncOperationWithResult(image);
            
            static NSString *const errorDescription = @"can not create image with given data";
            return asyncOperationWithError([JFFError newErrorWithDescription:errorDescription]);
        };
    };
}

@interface JFFImageCacheAdapter : NSObject<JFFRestKitCache>
@end

@implementation JFFImageCacheAdapter
{
    dispatch_queue_t _queue;
}

- (dispatch_queue_t)dispatchQueue
{
    if (self->_queue == NULL) {
        static const char *label = "com.embedded_sources.jffcache.thumbnail_storage";
        self->_queue = dispatch_queue_get_or_create(label, DISPATCH_QUEUE_CONCURRENT);
    }
    return self->_queue;
}

//TODO add read write locks
- (JFFAsyncOperation)loaderToSetData:(NSData *)data forKey:(NSString *)key
{
    return asyncOperationWithSyncOperation(^id(NSError *__autoreleasing *outError) {
        
        [[JFFCaches createThumbnailDB] setData:data forKey:key];
        return [NSNull new];
    });
}

- (JFFAsyncOperation)cachedDataLoaderForKey:(NSString *)key {
    return asyncOperationWithSyncOperation(^id(NSError *__autoreleasing *outError) {
        
        NSDate *date;
        NSData *data = [[JFFCaches createThumbnailDB] dataForKey:key lastUpdateTime:&date];
        
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
    });
}

@end

static id glStorageInstance = nil;

@interface JFFThumbnailStorage ()

@property (nonatomic) NSCache *imagesByUrl;

@end

@implementation JFFThumbnailStorage

- (NSCache *)imagesByUrl {
    if (!self->_imagesByUrl) {
        self->_imagesByUrl = [NSCache new];
    }
    
    return self->_imagesByUrl;
}

+ (JFFThumbnailStorage *)sharedStorage
{
    if (!glStorageInstance) {
        glStorageInstance = [self new];
    }
    
    return glStorageInstance;
}

+ (void)setSharedStorage:(JFFThumbnailStorage *)storage
{
    glStorageInstance = storage;
}

- (NSTimeInterval)cacheDataLifeTime
{
    NSNumber *timeToLiveInHours = [[JFFCaches createThumbnailDB] timeToLiveInHours];
    NSParameterAssert(timeToLiveInHours);
    return [timeToLiveInHours doubleValue]*3600.;
}

- (JFFImageCacheAdapter *)imageCacheAdapter
{
    JFFImageCacheAdapter *result = [JFFImageCacheAdapter new];
    return result;
}

- (JFFAsyncOperation)cachedInDBImageDataLoaderForUrl:(NSURL *)url
                             ignoreFreshDataLoadFail:(BOOL)ignoreFreshDataLoadFail
{
    JFFSmartUrlDataLoaderFields *args = [JFFSmartUrlDataLoaderFields new];
    args.urlBuilder = ^NSURL*() { return url; };
    args.cacheDataLifeTime = [self cacheDataLifeTime];
    args.doesNotIgnoreFreshDataLoadFail = ignoreFreshDataLoadFail;
    args.cache = [self imageCacheAdapter];
    
    args.dataLoaderForURL = ^JFFAsyncOperation(NSURL *url) {
        return asyncOperationWithSyncOperation(^id(NSError *__autoreleasing *outError) {
            NSData *data = [[NSData alloc]initWithContentsOfURL:url
                                                        options:NSDataReadingMappedIfSafe
                                                          error:outError];
            return data;
        });
    };
    //Do not cache invalid data here (may be no needs)
    args.analyzerForData = imageDataToUIImageBinder();
    
    JFFAsyncOperation loader = jSmartDataLoaderWithCache(args);
    
    return loader;
}

static id cacheKeyForURLScaleSizeAndContentMode(NSURL *url,
                                                CGSize scaleSize,
                                                UIViewContentMode contentMode)
{
    return  [[NSString alloc]initWithFormat:@"resized_image_key:%@<->%@<->%d",
             url,
             NSStringFromCGSize(scaleSize),
             contentMode];
}

- (JFFAsyncOperation)cachedScaleImageForSize:(CGSize)scaleSize
                                 contentMode:(UIViewContentMode)contentMode
                                         url:(NSURL *)url
                          dataToResizeLoader:(JFFAsyncOperation)dataToResizeLoader
{
    dataToResizeLoader = [dataToResizeLoader copy];
    
    JFFSmartUrlDataLoaderFields *args = [JFFSmartUrlDataLoaderFields new];
    args.urlBuilder = ^NSURL*() { return url; };
    args.cacheDataLifeTime = [self cacheDataLifeTime];
    args.cache = [self imageCacheAdapter];
    
    args.dataLoaderForURL = ^JFFAsyncOperation(NSURL *url) {
        JFFAsyncOperationBinder scaledImageBinder = ^JFFAsyncOperation(UIImage *image) {
            JFFSyncOperation loadDataBlock = ^(NSError *__autoreleasing *outError) {
                //TODO check error if can not resize
                //TODO try to reuse created here resized image for result
                UIImage *scaledImage = [image imageScaledToSize:scaleSize
                                                    contentMode:contentMode];
                
                NSData *result = UIImagePNGRepresentation(scaledImage);
                return result;
            };
            
            return asyncOperationWithSyncOperation(loadDataBlock);
        };
        
        return bindSequenceOfAsyncOperations(dataToResizeLoader,
                                             scaledImageBinder,
                                             nil);
    };
    //Do not cache invalid data here (may be no needs)
    args.analyzerForData = imageDataToUIImageBinder();
    
    args.cacheKeyForURL = ^id(NSURL *url) {
        return cacheKeyForURLScaleSizeAndContentMode(url, scaleSize, contentMode);
    };
    
    args.lastUpdateDateForKey = ^JFFAsyncOperation(NSURL *url) {
        return asyncOperationWithSyncOperation(^id(NSError *__autoreleasing *outError) {
            id< JFFCacheDB > thumbnailDB = [JFFCaches createThumbnailDB];
            NSDate *result = [thumbnailDB lastUpdateTimeForKey:[url description]];
            //TODO wich date pass when no date, maybe 1907 year????
            return result;
        });
    };
    
    JFFAsyncOperation loader = jSmartDataLoaderWithCache(args);
    
    return loader;
}

//TODO add load balancer here
- (JFFAsyncOperation)thumbnailLoaderForUrl:(NSURL *)url
{
    return ^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler progressCallback,
                                    JFFCancelAsyncOperationHandler cancelCallback,
                                    JFFDidFinishAsyncOperationHandler doneCallback) {
        JFFAsyncOperation loader = [self cachedInDBImageDataLoaderForUrl:url
                                                 ignoreFreshDataLoadFail:YES];
        
        //TODO: also check the last update date here
        JFFPropertyPath* propertyPath = [[JFFPropertyPath alloc]initWithName:@"imagesByUrl"
                                                                         key:url];
        
        loader = [self asyncOperationForPropertyWithPath:propertyPath
                                          asyncOperation:loader];
        
        return loader(progressCallback,
                      cancelCallback,
                      doneCallback);
    };
}

- (JFFAsyncOperation)thumbnailLoaderForUrl:(NSURL *)url
                              scaledToSize:(CGSize)scaleSize
                               contentMode:(UIViewContentMode)contentMode
{
    return ^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler progressCallback,
                                    JFFCancelAsyncOperationHandler cancelCallback,
                                    JFFDidFinishAsyncOperationHandler doneCallback) {
        JFFAsyncOperation loader = [self cachedInDBImageDataLoaderForUrl:url
                                                 ignoreFreshDataLoadFail:NO];
        
        loader = [self cachedScaleImageForSize:scaleSize
                                   contentMode:contentMode
                                           url:url
                            dataToResizeLoader:loader];
        
        id key = cacheKeyForURLScaleSizeAndContentMode(url, scaleSize, contentMode);
        
        //TODO: also check the last update date here
        JFFPropertyPath* propertyPath = [[JFFPropertyPath alloc]initWithName:@"imagesByUrl"
                                                                         key:key];
        
        loader = [self asyncOperationForPropertyWithPath:propertyPath
                                          asyncOperation:loader];
        
        return loader(progressCallback,
                      cancelCallback,
                      doneCallback);
    };
}

@end
