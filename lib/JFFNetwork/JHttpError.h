#import <JFFUtils/JFFError.h>

@interface JHttpError : JFFError

- (id)initWithHttpCode:(CFIndex)statusCode;

@end
