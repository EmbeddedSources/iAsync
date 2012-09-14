#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@class UIImage;

@interface JFFThumbnailStorage : NSObject

+ (JFFThumbnailStorage *)sharedStorage;
+ (void)setSharedStorage:(JFFThumbnailStorage *)storage;

- (UIImage *)imageForURL:(NSURL *)url;

- (JFFAsyncOperation)thumbnailLoaderForUrl:(NSURL *)url;

@end
