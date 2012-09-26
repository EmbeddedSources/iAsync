#import <JFFSocial/JFFSocialMediaItem.h>

#import <Foundation/Foundation.h>

extern NSString *const JFFMediaItemImageLowResolution     ;
extern NSString *const JFFMediaItemImageStandartResolution;
extern NSString *const JFFMediaItemImageThumbnail         ;

@class JFFInstagramAccount;

@interface JFFInstagramMediaItem : JFFSocialMediaItem

@property (nonatomic) NSString *mediaType;

@property (nonatomic) JFFInstagramAccount *user;
@property (nonatomic) NSDictionary *images;

@end
