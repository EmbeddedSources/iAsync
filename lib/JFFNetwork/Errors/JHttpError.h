#import <JFFNetwork/Errors/JNetworkError.h>

@interface JHttpError : JNetworkError

@property (nonatomic) id<NSCopying> context;

- (id)initWithHttpCode:(CFIndex)statusCode;

- (BOOL)isHttpNotChangedError;
- (BOOL)isServiceUnavailableError;
- (BOOL)isInternalServerError;

@end
