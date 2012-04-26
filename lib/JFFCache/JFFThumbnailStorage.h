#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@class UIImage;

@interface JFFThumbnailStorage : NSObject

+(JFFThumbnailStorage*)sharedStorage;
+(void)setSharedStorage:( JFFThumbnailStorage* )storage_;

-(UIImage*)imageForURL:( NSURL* )url_;

-(JFFAsyncOperation)thumbnailLoaderForUrl:( NSURL* )url_;

@end
