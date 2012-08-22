#import "JFFThumbnailStorage.h"

#import "JFFCacheDB.h"
#import "JFFCaches.h"

#import <UIKit/UIKit.h>

static id storageInstance_ = nil;

@interface JFFThumbnailStorage ()

@property ( nonatomic ) NSMutableDictionary* imagesByUrl;

@end

@implementation JFFThumbnailStorage

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
    if ( !self->_imagesByUrl )
    {
        self->_imagesByUrl = [ NSMutableDictionary new ];
    }

    return self->_imagesByUrl;
}

+(JFFThumbnailStorage*)sharedStorage
{
    if ( !storageInstance_ )
    {
        storageInstance_ = [ self new ];
    }

    return storageInstance_;
}

-(void)handleMemoryWarning:( NSNotification* )notification_
{
    self->_imagesByUrl = nil;
}

+(void)setSharedStorage:( JFFThumbnailStorage* )storage_
{
    storageInstance_ = storage_;
}

-(id< JFFCacheDB >)thumbnailDB
{
    return [ [ JFFCaches sharedCaches ] thumbnailDB ];
}

-(UIImage*)cachedImageForURL:( NSURL* )url_
{
    NSString* urlString_ = [ url_ description ];
    NSData* chachedData_ = [ [ self thumbnailDB ] dataForKey: urlString_ ];

    UIImage* resultImage_ = chachedData_ ? [ UIImage imageWithData: chachedData_ ] : nil;
    if ( chachedData_ && !resultImage_ )
        NSLog( @"JFFThumbnailStorage: can not create image from cache with url: %@", url_ );

    return resultImage_;
}

-(JFFAsyncOperationBinder)createImageBlockWithUrl:( NSURL* )url_
{
    JFFAnalyzer analyzer_ = ^id( NSData* imageData_, NSError** outError_ )
    {
        UIImage* resultImage_ = [ [ UIImage alloc ] initWithData: imageData_ ];

        if ( resultImage_ )
        {
            [ [ self thumbnailDB ] setData: imageData_
                                    forKey: [ url_ description ] ];

            return resultImage_;
        }

        NSLog( @"JFFThumbnailStorage: can not create image from cache with url: %@", url_ );
        if ( outError_ )
        {
            NSError* error_ = [ JFFError newErrorWithDescription: @"invalid response" ];
            [ error_ setToPointer: outError_ ];
        }

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
            if ( doneCallback_ )
                doneCallback_( nil, [ JFFError newErrorWithDescription: @"incorrect url" ] );
            return JFFStubCancelAsyncOperationBlock;
        }

        UIImage* cachedImage_ = self.imagesByUrl[ url_ ];
        if ( cachedImage_ )
        {
            if ( doneCallback_ )
                doneCallback_( cachedImage_, nil );
            return JFFStubCancelAsyncOperationBlock;
        }

        cachedImage_ = [ self cachedImageForURL: url_ ];
        if ( cachedImage_ )
        {
            self.imagesByUrl[ url_ ] = cachedImage_;
            if ( doneCallback_ )
                doneCallback_( cachedImage_, nil );
            return JFFStubCancelAsyncOperationBlock;
        }

        JFFAsyncOperation loaderBlock_ = asyncOperationWithSyncOperation( ^id( NSError** error_ )
        {
            return [ [ NSData alloc ] initWithContentsOfURL: url_
                                                    options: NSDataReadingMappedIfSafe
                                                      error: error_ ];
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
    return self->_imagesByUrl[ url_ ];
}

@end
