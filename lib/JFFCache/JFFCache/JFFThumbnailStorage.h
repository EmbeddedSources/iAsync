#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <UIKit/UIKit.h>

extern NSString *JFFNoImageDataURLString;

@interface JFFThumbnailStorage : NSObject

+ (instancetype)sharedStorage;
+ (void)setSharedStorage:(JFFThumbnailStorage *)storage;

- (JFFAsyncOperation)thumbnailLoaderForUrl:(NSURL *)url;

- (JFFAsyncOperation)tryThumbnailLoaderForUrls:(NSArray *)urls;

- (void)resetCache;

@end
