#import "UIImageView+CachedAsyncImageLoader.h"

#import "JFFThumbnailStorage.h"

@interface UIImageView (CachedAsyncImageLoaderInternal)

@property (nonatomic) NSURL *jffAsycImageURL;
@property (nonatomic) NSURL *jffAsycLoadedImageURL;

@end

@implementation UIImageView (CachedAsyncImageLoaderInternal)

@dynamic
jffAsycImageURL,
jffAsycLoadedImageURL;

+ (void)load
{
    jClass_implementProperty(self, NSStringFromSelector(@selector(jffAsycImageURL      )));
    jClass_implementProperty(self, NSStringFromSelector(@selector(jffAsycLoadedImageURL)));
}

@end

@implementation UIImageView (CachedAsyncImageLoader)

- (void)jffSetImage:(UIImage *)image URL:(NSURL *)url
{
    if (!image || self.jffAsycImageURL != url)
        return;
    
    self.jffAsycLoadedImageURL = url;
    self.image = image;
}

- (void)setImageWithURL:(NSURL *)url andPlaceholder:(UIImage *)placeholder
{
    if ([self.jffAsycLoadedImageURL isEqual:url]) {
        return;
    }
    
    self.image           = placeholder;
    self.jffAsycImageURL = url;
    
    __weak UIImageView *weakSelf = self;
    
    JFFDidFinishAsyncOperationCallback doneCallback = ^(UIImage *result, NSError *error) {
        
        [error writeErrorWithJFFLogger];
        [weakSelf jffSetImage:result URL:url];
    };
    
    JFFThumbnailStorage *storage = [JFFThumbnailStorage sharedStorage];
    
    [storage thumbnailLoaderForUrl:url](nil, nil, doneCallback);
}

@end
