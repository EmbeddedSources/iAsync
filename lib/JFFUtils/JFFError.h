#import <Foundation/Foundation.h>

@interface JFFError : NSError

-(id)initWithDescription:( NSString* )description_
                  domain:( NSString* )domain_
                    code:( NSInteger )code_;

-(id)initWithDescription:( NSString* )description_;
+(id)newErrorWithDescription:( NSString* )description_;

+(id)errorWithDescription:( NSString* )description_ code:( NSInteger )code_;

@end
