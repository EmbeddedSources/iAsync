#import <JFFCache/Errors/JFFCacheError.h>

@interface JFFCacheLoadImageError : JFFCacheError

@property (nonatomic) NSError *nativeError;

@end
