#import <Foundation/Foundation.h>

@class JFFInstagramAccount;

@interface JFFInstagramMediaItem : NSObject

@property (nonatomic) NSString            *mediaItemId;
@property (nonatomic) JFFInstagramAccount *user;

@end
