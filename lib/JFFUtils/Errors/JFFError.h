#import <Foundation/Foundation.h>

@interface JFFError : NSError

- (instancetype)initWithDescription:(NSString *)description
                             domain:(NSString *)domain
                               code:(NSInteger)code;

- (instancetype)initWithDescription:(NSString *)description;
+ (instancetype)newErrorWithDescription:(NSString *)description;

+ (instancetype)newErrorWithDescription:(NSString *)description
                                   code:(NSInteger)code;

@end
