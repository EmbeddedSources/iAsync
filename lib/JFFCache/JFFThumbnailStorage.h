#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <UIKit/UIKit.h>

@interface JFFThumbnailStorage : NSObject

+ (JFFThumbnailStorage *)sharedStorage;
+ (void)setSharedStorage:(JFFThumbnailStorage *)storage;

- (JFFAsyncOperation)thumbnailLoaderForUrl:(NSURL *)url;

- (JFFAsyncOperation)thumbnailLoaderForUrl:(NSURL *)url
                              scaledToSize:(CGSize)scaleSize
                               contentMode:(UIViewContentMode)contentMode;

@end
