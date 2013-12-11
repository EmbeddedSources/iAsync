#import <JFFNetwork/Errors/JNetworkError.h>

@interface JHttpError : JFFError

@property (nonatomic, strong) id<NSCopying> context;

- (id)initWithHttpCode:(CFIndex)statusCode;

-(BOOL)isHttpNotChangedError;
-(BOOL)isServiceUnavailableError;
-(BOOL)isInternalServerError;
-(BOOL)isNotFoundError;

@end
