#import <Foundation/Foundation.h>

@class JFFTwitterAccount;

@interface JFFTweet : NSObject

@property (nonatomic) NSString          *tweetId;
@property (nonatomic) NSString          *text;
@property (nonatomic) JFFTwitterAccount *user;

@end
