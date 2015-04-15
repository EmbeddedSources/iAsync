#import <JFFSocial/Errors/JFFSocialError.h>

#import <Foundation/Foundation.h>

@interface JFFInvalidInstagramResponseURLError : JFFSocialError

@property (nonatomic) NSURL *url;

@end
