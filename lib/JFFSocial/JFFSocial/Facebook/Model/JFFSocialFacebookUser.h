#import <Foundation/Foundation.h>

@interface JFFSocialFacebookUser : NSObject <NSCopying>

@property (nonatomic) NSString *facebookID;
@property (nonatomic) NSString *email;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *gender;
@property (nonatomic) NSDate   *birthday;
@property (nonatomic) NSString *biography;

@property (nonatomic, readonly) NSURL *largeImageURL;

- (NSURL *)imageURLForSize:(CGSize)size;

@end
