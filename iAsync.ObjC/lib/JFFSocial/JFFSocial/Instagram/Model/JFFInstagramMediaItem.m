#import "JFFInstagramMediaItem.h"

#import "JFFInstagramMediaItemImage.h"

NSString *const JFFMediaItemImageLowResolution      = @"low_resolution";
NSString *const JFFMediaItemImageStandartResolution = @"standard_resolution";
NSString *const JFFMediaItemImageThumbnail          = @"thumbnail";

@implementation JFFInstagramMediaItem

- (NSURL *)imageURLForKey:(id)key
{
    JFFInstagramMediaItemImage *image = self.images[key];
    NSParameterAssert([image isKindOfClass:[JFFInstagramMediaItemImage class]]);
    return image.url;
}

- (NSURL *)bigImageUrl
{
    return [self imageURLForKey:JFFMediaItemImageStandartResolution];
}

- (NSURL *)thumbnailImageUrl
{
    return [self imageURLForKey:JFFMediaItemImageThumbnail];
}

@end
