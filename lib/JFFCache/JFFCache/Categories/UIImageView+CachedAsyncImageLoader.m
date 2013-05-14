#import "UIImageView+CachedAsyncImageLoader.h"

#import "JFFThumbnailStorage.h"

@interface UIImageView (CachedAsyncImageLoaderInternal)

@property (nonatomic) NSURL *jffAsycImageURL;

@end

@implementation UIImageView (CachedAsyncImageLoaderInternal)

@dynamic jffAsycImageURL;

+ (void)load
{
    jClass_implementProperty(self, @"jffAsycImageURL");
}

@end

@implementation UIImageView (CachedAsyncImageLoader)

- (void)jffSetImage:(UIImage *)image URL:(NSURL *)url
{
    if (!image || self.jffAsycImageURL != url)
        return;
    
    self.image = image;
}

- (void)setImageWithURL:(NSURL *)url andPlaceholder:(UIImage *)placeholder
{
    self.image           = placeholder;
    self.jffAsycImageURL = url;
    
    __weak UIImageView *weakSelf = self;
    
    JFFDidFinishAsyncOperationHandler doneCallback = ^(UIImage *result, NSError *error) {
        
        [error writeErrorWithJFFLogger];
        [weakSelf jffSetImage:result URL:url];
    };
    
    JFFThumbnailStorage *storage = [JFFThumbnailStorage sharedStorage];
    
    [storage thumbnailLoaderForUrl:url](nil, nil, doneCallback);
}

@end
