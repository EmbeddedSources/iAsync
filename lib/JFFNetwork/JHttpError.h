#import <JFFNetwork/Errors/JNetworkError.h>

@interface JHttpError : JFFError

@property (nonatomic) id<NSCopying> context;

- (id)initWithHttpCode:(CFIndex)statusCode;

-(BOOL)isHttpNotChangedError;
-(BOOL)isServiceUnavailableError;
-(BOOL)isInternalServerError;

@end
