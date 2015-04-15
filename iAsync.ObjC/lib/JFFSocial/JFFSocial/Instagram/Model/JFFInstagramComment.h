#import <Foundation/Foundation.h>

@class JFFInstagramAccount;

@interface JFFInstagramComment : NSObject

@property (nonatomic) NSString            *text;
@property (nonatomic) JFFInstagramAccount *from;

@end
