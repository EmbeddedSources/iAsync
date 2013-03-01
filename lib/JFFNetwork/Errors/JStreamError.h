#import <JFFNetwork/Errors/JNetworkError.h>

#import <Foundation/Foundation.h>

@interface JStreamError : JNetworkError

@property (nonatomic, readonly) CFStreamError rawError;

- (id)initWithStreamError:(CFStreamError)rawError;

@end
