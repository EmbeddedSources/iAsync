#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@class UIImage;

@interface JFFThumbnailStorage : NSObject

+ (JFFThumbnailStorage *)sharedStorage;
+ (void)setSharedStorage:(JFFThumbnailStorage *)storage;

- (JFFAsyncOperation)thumbnailLoaderForUrl:(NSURL *)url;

//TODO include constant UIViewContentMode here
- (JFFAsyncOperation)thumbnailLoaderForUrl:(NSURL *)url
                              scaledToSize:(CGSize)scaleSize
                               contentMode:(UIViewContentMode)contentMode;

@end
