#import <JFFNetwork/Errors/JNetworkError.h>

#import <Foundation/Foundation.h>

@interface JHttpError : JNetworkError

@property (nonatomic) id<NSCopying> context;

- (instancetype)initWithHttpCode:(CFIndex)statusCode;

- (BOOL)isHttpNotChangedError;
- (BOOL)isServiceUnavailableError;
- (BOOL)isInternalServerError;
- (BOOL)isNotFoundError;

@end
