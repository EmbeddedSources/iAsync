#import <JFFSocial/Errors/JFFSocialError.h>

#import <Foundation/Foundation.h>

@interface JFFInstagramResponseError : JFFSocialError

@property (nonatomic) NSUInteger errorCode;
@property (nonatomic) NSString  *errorType;
@property (nonatomic) NSString  *errorMessage;

@end
