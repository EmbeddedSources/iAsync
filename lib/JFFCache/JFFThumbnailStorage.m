#import "JFFThumbnailStorage.h"

#import "JFFCacheDB.h"
#import "JFFCaches.h"

#import <UIKit/UIKit.h>

static id storage_instance_ = nil;

@interface JFFThumbnailStorage ()

@property ( nonatomic ) NSMutableDictionary* imagesByUrl;

@end

@implementation JFFThumbnailStorage

@synthesize imagesByUrl = _imagesByUrl;

-(id)init
{
    self = [ super init ];

    if ( self )
    {
        [ [ NSNotificationCenter defaultCenter ] addObserver: self
                                                    selector: @selector( handleMemoryWarning: )
                                                        name: UIApplicationDidReceiveMemoryWarningNotification
                                                      object: [ UIApplication sharedApplication ] ];
    }

    return self;
}

-(void)dealloc
{
    [ [ NSNotificationCenter defaultCenter ] removeObserver: self ];
}

-(NSMutableDictionary*)imagesByUrl
{
    if ( !_imagesByUrl )
    {
        _imagesByUrl = [ NSMutableDictionary new ];
    }

    return _imagesByUrl;
}

+(JFFThumbnailStorage*)sharedStorage
{
    if ( !storage_instance_ )
    {
        storage_instance_ = [ self new ];
    }

    return storage_instance_;
}

-(void)handleMemoryWarning:( NSNotification* )notification_
{
    self.imagesByUrl = nil;
}

+(void)setSharedStorage:( JFFThumbnailStorage* )storage_
{
    storage_instance_ = storage_;
}

-(id< JFFCacheDB >)thumbnailDB
{
    return [ [ JFFCaches sharedCaches ] thumbnailDB ];
}

-(UIImage*)cachedImageForURL:( NSURL* )url_
{
    NSString* url_string_ = [ url_ description ];
    NSData* chached_data_ = [ [ self thumbnailDB ] dataForKey: url_string_ ];

    UIImage* result_image_ = chached_data_ ? [ UIImage imageWithData: chached_data_ ] : nil;
    if ( chached_data_ && !result_image_ )
        NSLog( @"JFFThumbnailStorage: can not create image from cache with url: %@", url_ );
    return result_image_;
}

-(JFFAsyncOperationBinder)createImageBlockWithUrl:( NSURL* )url_
{
    JFFAnalyzer analyzer_ = ^id( NSData* imageData_, NSError** outError_ )
    {
        UIImage* resultImage_ = [ UIImage imageWithData: imageData_ ];

        if ( resultImage_ )
        {
            [ [ self thumbnailDB ] setData: imageData_
                                    forKey: [ url_ description ] ];

            return resultImage_;
        }

        NSLog( @"JFFThumbnailStorage: can not create image from cache with url: %@", url_ );
        NSError* error_ = [ JFFError errorWithDescription: @"invalid response" ];
        [ error_ setToPointer: outError_ ];

        return nil;
    };
    return asyncOperationBinderWithAnalyzer( analyzer_ );
}

-(JFFAsyncOperation)thumbnailLoaderForUrl:( NSURL* )url_
{
    return ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progress_callback_
                                    , JFFCancelAsyncOperationHandler cancel_callback_
                                    , JFFDidFinishAsyncOperationHandler doneCallback_ )
    {
        if ( !url_ )
        {
            doneCallback_( nil, [ JFFError errorWithDescription: @"incorrect url" ] );
            return JFFStubCancelAsyncOperationBlock;
        }

        UIImage* cachedImage_ = [ self.imagesByUrl objectForKey: url_ ];
        if ( cachedImage_ )
        {
            doneCallback_( cachedImage_, nil );
            return JFFStubCancelAsyncOperationBlock;
        }

        cachedImage_ = [ self cachedImageForURL: url_ ];
        if ( cachedImage_ )
        {
            [ self.imagesByUrl setObject: cachedImage_ forKey: url_ ];
            doneCallback_( cachedImage_, nil );
            return JFFStubCancelAsyncOperationBlock;
        }

        JFFAsyncOperation loaderBlock_ = asyncOperationWithSyncOperation( ^id( NSError** error_ )
        {
            return [ NSData dataWithContentsOfURL: url_ options: NSDataReadingMappedIfSafe error: error_ ];
        } );
        //loader_block_ = balancedAsyncOperation( loader_block_ );

        JFFAsyncOperationBinder createImageBlock_ = [ self createImageBlockWithUrl: url_ ];

        loaderBlock_ = bindSequenceOfAsyncOperations( loaderBlock_, createImageBlock_, nil );

        JFFPropertyPath* propertyPath_ = [ [ JFFPropertyPath alloc ] initWithName: @"imagesByUrl"
                                                                              key: url_ ];

        JFFAsyncOperation asyncLoader_ = [ self asyncOperationForPropertyWithPath: propertyPath_
                                                                   asyncOperation: loaderBlock_ ];
        return asyncLoader_( progress_callback_, cancel_callback_, doneCallback_ );
    };
}

-(UIImage*)imageForURL:( NSURL* )url_
{
    return [ self.imagesByUrl objectForKey: url_ ];
}

@end
