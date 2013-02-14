#import "UIImageView+CachedAsyncImageLoader.h"

#import <JFFCache/JFFCache.h>

#include <objc/runtime.h>

static char imageURLKey;

@implementation UIImageView (CachedAsyncImageLoader)

- (NSURL *)jffAsycImageURL
{
    return objc_getAssociatedObject(self, &imageURLKey);
}

- (void)setJffAsycImageURL:(NSURL *)url
{
    objc_setAssociatedObject(self,
                             &imageURLKey,
                             url,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

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
