#import "JFFThumbnailStorage.h"

#import "JFFCacheDB.h"
#import "JFFCaches.h"

#import <JFFRestKit/JFFRestKit.h>
#import <JFFNetwork/JFFNetworkBlocksFunctions.h>

#import <UIKit/UIKit.h>

static NSString *const cacheQueueName = @"com.embedded_sources.jffcache.thumbnail_storage.cache";

//TODO try to use NSURLCache
static JFFAsyncBinderForIdentifier imageDataToUIImageBinder()
{
    return ^JFFAsyncOperationBinder(NSURL *url) {
        
        return ^JFFAsyncOperation(NSData *imageData) {
            
            UIImage *image = [UIImage imageWithData:imageData];
            
            if (image)
                return asyncOperationWithResult(image);
            
            static NSString *const errorDescription = @"can not create image with given data";
            return asyncOperationWithError([JFFError newErrorWithDescription:errorDescription]);
        };
        // TODO: Test perfomance
//        return ^JFFAsyncOperation(NSData *imageData) {
//            return asyncOperationWithSyncOperation(^id(NSError *__autoreleasing *outError) {
//                UIImage *image = [UIImage imageWithData:imageData];
//                
//                if (!image) {
//                    static NSString *const errorDescription = @"can not create image with given data";
//                    *outError = [JFFError newErrorWithDescription:errorDescription];
//                }
//                return image;
//            });
//        };
    };
}

//TODO refactor this
static JFFLimitedLoadersQueue *balancer(void)
{
    static dispatch_once_t once;
    static JFFLimitedLoadersQueue *instance;
    dispatch_once(&once, ^{
        instance = [JFFLimitedLoadersQueue new];
    });
    return instance;
}

static JFFAsyncOperation balanced(JFFAsyncOperation loader)
{
    return [balancer() balancedLoaderWithLoader:loader];
}

@interface JFFImageCacheAdapter : JFFCacheAdapter
@end

@implementation JFFImageCacheAdapter

+ (id)new
{
    return [self newCacheAdapterWithCacheFactory:^id{return [JFFCaches createThumbnailDB];}
                                  cacheQueueName:cacheQueueName];
}

- (JFFAsyncOperation)loaderToSetData:(NSData *)data forKey:(NSString *)key
{
    JFFAsyncOperation loader = [super loaderToSetData:data forKey:key];
    return balanced(loader);
}

- (JFFAsyncOperation)cachedDataLoaderForKey:(NSString *)key {
    
    JFFAsyncOperation loader = [super cachedDataLoaderForKey:key];
    return balanced(loader);
}

@end

static JFFThumbnailStorage *glStorageInstance = nil;

@interface JFFThumbnailStorage ()

@property (nonatomic) NSCache *imagesByUrl;

@end

@implementation JFFThumbnailStorage

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init
{
    self = [super init];
    
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onMemoryWarning:)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
    }
    
    return self;
}

- (NSCache *)imagesByUrl {
    if (!self->_imagesByUrl) {
        self->_imagesByUrl = [NSCache new];
        [self->_imagesByUrl setCountLimit:200];
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

+ (NSTimeInterval)cacheDataLifeTimeInSeconds
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

+ (JFFAsyncOperation)onThreadLoadUrl:(NSURL *)url
{
    return asyncOperationWithSyncOperation(^id(NSError *__autoreleasing *outError) {
        
        NSData *imageData = [NSData dataWithContentsOfURL:url
                                                  options:NSDataReadingUncached
                                                    error:outError];
        return imageData;
    });
}

- (JFFAsyncOperation)cachedInDBImageDataLoaderForUrl:(NSURL *)url
                             ignoreFreshDataLoadFail:(BOOL)ignoreFreshDataLoadFail
{
    JFFSmartUrlDataLoaderFields *args = [JFFSmartUrlDataLoaderFields new];
    args.loadDataIdentifier = url;
    args.cacheDataLifeTimeInSeconds = [[self class] cacheDataLifeTimeInSeconds];
    args.doesNotIgnoreFreshDataLoadFail = ignoreFreshDataLoadFail;
    args.cache = [self imageCacheAdapter];
    
    args.dataLoaderForIdentifier = ^JFFAsyncOperation(id identifier) {
        assert([identifier isKindOfClass:[NSURL class]]);
        JFFAsyncOperation dataLoader =
        //liveDataURLResponseLoader(identifier, nil, nil);
        dataURLResponseLoader(identifier, nil, nil);
        //[[self class] onThreadLoadUrl:url];
        
        return dataLoader;
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
    return  [[NSString alloc] initWithFormat:@"resized_image_key:%@<->%@<->%d",
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
    args.loadDataIdentifier = ^id() { return url; };
    args.cacheDataLifeTimeInSeconds = [[self class] cacheDataLifeTimeInSeconds];
    args.cache = [self imageCacheAdapter];
    
    args.dataLoaderForIdentifier = ^JFFAsyncOperation(NSURL *url) {
        JFFAsyncOperationBinder scaledImageBinder = ^JFFAsyncOperation(UIImage *image) {
            JFFSyncOperation loadDataBlock = ^(NSError *__autoreleasing *outError) {
                //TODO check error if can not resize
                //TODO try to reuse created here resized image for result
                UIImage *scaledImage = [image imageScaledToSize:scaleSize
                                                    contentMode:contentMode];
                
                NSData *result = UIImagePNGRepresentation(scaledImage);
                return result;
            };
            
            return asyncOperationWithSyncOperationAndQueue(loadDataBlock,
                                                           "com.embedded_sources.jffcache.thumbnail_storage.cache.resize");
        };
        
        return bindSequenceOfAsyncOperations(dataToResizeLoader,
                                             scaledImageBinder,
                                             nil);
    };
    //Do not cache invalid data here (may be no needs)
    args.analyzerForData = imageDataToUIImageBinder();
    
    args.cacheKeyForIdentifier = ^id(NSURL *url) {
        return cacheKeyForURLScaleSizeAndContentMode(url, scaleSize, contentMode);
    };
    
    args.lastUpdateDateForKey = ^JFFAsyncOperation(NSURL *url) {
        JFFAsyncOperation loader = asyncOperationWithSyncOperationAndQueue(^id(NSError *__autoreleasing *outError) {
            
            id< JFFCacheDB > thumbnailDB = [JFFCaches createThumbnailDB];
            NSDate *result = [thumbnailDB lastUpdateTimeForKey:[url description]];
            //TODO wich date pass when no date, maybe 1907 year????
            return result;
        }, [cacheQueueName cStringUsingEncoding:NSUTF8StringEncoding]);
        
        return balanced(loader);
    };
    
    JFFAsyncOperation loader = jSmartDataLoaderWithCache(args);
    
    return loader;
}

//TODO add load balancer here
- (JFFAsyncOperation)thumbnailLoaderForUrl:(NSURL *)url
{
    if (url) {
        assert([url isKindOfClass:[NSURL class]]);
    } else {
        return asyncOperationWithError([JFFError newErrorWithDescription:@"can not load image: no url"]);
    }
    
    return ^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler progressCallback,
                                    JFFCancelAsyncOperationHandler cancelCallback,
                                    JFFDidFinishAsyncOperationHandler doneCallback) {
        
        JFFAsyncOperation loader = [self cachedInDBImageDataLoaderForUrl:url
                                                 ignoreFreshDataLoadFail:YES];
        
        //TODO: also check the last update date here
        JFFPropertyPath* propertyPath = [[JFFPropertyPath alloc] initWithName:@"imagesByUrl"
                                                                          key:url];
        
        loader = [self asyncOperationForPropertyWithPath:propertyPath
                                          asyncOperation:loader];
        
        return loader(progressCallback,
                      cancelCallback,
                      doneCallback);
    };
}

//It is slow, at least add 1 sec to wait
- (JFFAsyncOperation)thumbnailLoaderForUrl:(NSURL *)url
                              scaledToSize:(CGSize)scaleSize
                               contentMode:(UIViewContentMode)contentMode
{
    if (url) {
        assert([url isKindOfClass:[NSURL class]]);
    } else {
        return asyncOperationWithError([JFFError newErrorWithDescription:@"can not load image: no url"]);
    }
    
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
        JFFPropertyPath* propertyPath = [[JFFPropertyPath alloc] initWithName:@"imagesByUrl"
                                                                          key:key];
        
        loader = [self asyncOperationForPropertyWithPath:propertyPath
                                          asyncOperation:loader];
        
        return loader(progressCallback,
                      cancelCallback,
                      doneCallback);
    };
}

#pragma Memory warning

- (void)resetCache
{
    [_imagesByUrl removeAllObjects];
}

- (void)onMemoryWarning:(NSNotification *)notification
{
    [self resetCache];
}

@end
