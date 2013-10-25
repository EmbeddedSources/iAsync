#import <JFFCache/Errors/JFFCacheError.h>

@class NSError;

@interface JFFCacheLoadImageError : JFFCacheError

@property (nonatomic) NSError *nativeError;

@end
