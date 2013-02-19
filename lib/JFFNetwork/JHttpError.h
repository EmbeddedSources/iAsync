#import <JFFUtils/JFFError.h>

@interface JHttpError : JFFError

@property (nonatomic) id<NSCopying> context;

- (id)initWithHttpCode:(CFIndex)statusCode;

@end
