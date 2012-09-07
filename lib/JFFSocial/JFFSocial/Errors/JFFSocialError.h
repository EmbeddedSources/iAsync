#import <Foundation/Foundation.h>

@interface JFFSocialError : NSError

-(id)initWithDescription:( NSString* )description_
                  domain:( NSString* )domain_
                    code:( NSInteger )code_;

-(id)initWithDescription:( NSString* )description_;
+(id)newErrorWithDescription:( NSString* )description_;

@end
