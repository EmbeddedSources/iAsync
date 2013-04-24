#import <Foundation/Foundation.h>

@interface JFFError : NSError

- (id)initWithDescription:(NSString *)description
                   domain:(NSString *)domain
                     code:(NSInteger)code;

- (id)initWithDescription:(NSString *)description;
+ (id)newErrorWithDescription:(NSString *)description;

+ (id)newErrorWithDescription:(NSString *)description
                         code:(NSInteger)code;

@end
