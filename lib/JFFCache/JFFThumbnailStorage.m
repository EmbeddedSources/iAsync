#import "JFFThumbnailStorage.h"

#import "JFFCacheDB.h"
#import "JFFCaches.h"

#import <UIKit/UIKit.h>

static id glStorageInstance = nil;

@interface JFFThumbnailStorage ()

@property (nonatomic) NSMutableDictionary *imagesByUrl;

@end

@implementation JFFThumbnailStorage

- (id)init
{
    self = [super init];

    if ( self )
    {
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(handleMemoryWarning:)
                                                    name:UIApplicationDidReceiveMemoryWarningNotification
                                                  object:[UIApplication sharedApplication]];
    }

    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(NSMutableDictionary*)imagesByUrl
{
    if (!self->_imagesByUrl)
    {
        self->_imagesByUrl = [NSMutableDictionary new];
    }

    return self->_imagesByUrl;
}

+(JFFThumbnailStorage*)sharedStorage
{
    if ( !glStorageInstance )
    {
        glStorageInstance = [self new];
    }

    return glStorageInstance;
}

-(void)handleMemoryWarning:(NSNotification *)notification
{
    self->_imagesByUrl = nil;
}

+(void)setSharedStorage:(JFFThumbnailStorage *)storage
{
    glStorageInstance = storage;
}

-(id< JFFCacheDB >)thumbnailDB
{
    return [[JFFCaches sharedCaches]thumbnailDB];
}

- (UIImage *)cachedImageForURL:(NSURL *)url
{
    NSString* urlString = [url description];
    NSData* chachedData = [[self thumbnailDB]dataForKey:urlString];

    UIImage *resultImage = chachedData?[UIImage imageWithData:chachedData]:nil;
    if (chachedData && !resultImage)
        NSLog(@"JFFThumbnailStorage: can not create image from cache with url: %@", url);

    return resultImage;
}

- (JFFAsyncOperationBinder)createImageBlockWithUrl:(NSURL *)url
{
    JFFAnalyzer analyzer = ^id(NSData *imageData, NSError **outError)
    {
        UIImage *resultImage = [[UIImage alloc]initWithData:imageData];

        if (resultImage)
        {
            //TODO set data in separate thread !!!! ?????
            [[self thumbnailDB]setData:imageData
                                forKey:[url description]];

            return resultImage;
        }

        NSLog( @"JFFThumbnailStorage: can not create image from cache with url: %@", url );
        if (outError)
        {
            NSError *error = [JFFError newErrorWithDescription:@"invalid response"];
            [error setToPointer:outError];
        }

        return nil;
    };
    return asyncOperationBinderWithAnalyzer(analyzer);
}

- (JFFAsyncOperation)thumbnailLoaderForUrl:(NSURL *)url
{
    return ^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler progressCallback,
                                    JFFCancelAsyncOperationHandler cancelCallback,
                                    JFFDidFinishAsyncOperationHandler doneCallback)
    {
        if (!url)
        {
            if (doneCallback)
                doneCallback(nil, [JFFError newErrorWithDescription:@"incorrect url"]);
            return JFFStubCancelAsyncOperationBlock;
        }

        //TODO remove redundant cache logic
        UIImage *cachedImage = self.imagesByUrl[url];
        if (cachedImage)
        {
            if (doneCallback)
                doneCallback(cachedImage, nil);
            return JFFStubCancelAsyncOperationBlock;
        }

        //TODO remove redundant cache logic
        cachedImage = [self cachedImageForURL:url];
        if ( cachedImage )
        {
            self.imagesByUrl[url] = cachedImage;
            if (doneCallback)
                doneCallback cachedImage, nil );
            return JFFStubCancelAsyncOperationBlock;
        }

        JFFAsyncOperation loaderBlock = asyncOperationWithSyncOperation(^id(NSError **error)
        {
            return [[NSData alloc]initWithContentsOfURL:url
                                                options:NSDataReadingMappedIfSafe
                                                  error:error];
        } );
        //loader_block_ = balancedAsyncOperation( loader_block_ );

        JFFAsyncOperationBinder createImageBlock = [self createImageBlockWithUrl:url];

        loaderBlock = bindSequenceOfAsyncOperations(loaderBlock, createImageBlock, nil);

        JFFPropertyPath* propertyPath = [[JFFPropertyPath alloc]initWithName:@"imagesByUrl"
                                                                         key:url];

        JFFAsyncOperation asyncLoader = [self asyncOperationForPropertyWithPath:propertyPath
                                                                 asyncOperation:loaderBlock];
        return asyncLoader(progressCallback, cancelCallback, doneCallback);
    };
}

-(UIImage*)imageForURL:( NSURL* )url_
{
    return self->_imagesByUrl[ url_ ];
}

@end
